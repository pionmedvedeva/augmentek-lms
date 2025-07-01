import * as functions from 'firebase-functions';
import { getStorage } from 'firebase-admin/storage';
import * as path from 'path';
import * as os from 'os';
import * as fs from 'fs';

// Правильный импорт pdf2pic
const pdf2pic = require('pdf2pic');

/**
 * Конвертирует PDF файл в набор изображений (PNG)
 * Принимает URL PDF файла, возвращает массив URL изображений страниц
 */
export const convertPdfToImages = functions.https.onCall(async (data: any, context) => {
  try {
    const { pdfUrl, documentId } = data as { pdfUrl: string; documentId: string };
    
    if (!pdfUrl || !documentId) {
      throw new functions.https.HttpsError('invalid-argument', 'PDF URL and document ID are required');
    }

    console.log(`🔄 Converting PDF to images: ${pdfUrl}`);
    
    // Скачиваем PDF файл
    const response = await fetch(pdfUrl);
    if (!response.ok) {
      throw new functions.https.HttpsError('not-found', 'Failed to download PDF file');
    }
    
    const pdfBuffer = await response.arrayBuffer();
    const tempPdfPath = path.join(os.tmpdir(), `${documentId}.pdf`);
    
    // Сохраняем PDF во временный файл
    fs.writeFileSync(tempPdfPath, Buffer.from(pdfBuffer));
    
    // Настройки конвертации
    const convert = pdf2pic.fromPath(tempPdfPath, {
      density: 100,           // DPI качества
      saveFilename: "page",   // Имя файла
      savePath: os.tmpdir(),  // Временная папка
      format: "png",          // Формат изображения
      width: 800,             // Ширина изображения
      height: 1132            // Высота (соотношение A4)
    });

    // Конвертируем все страницы
    const convertResults = await convert.bulk(-1); // -1 = все страницы
    
    console.log(`📄 Converted ${convertResults.length} pages`);
    
    // Загружаем изображения в Firebase Storage
    const bucket = getStorage().bucket();
    const imageUrls: string[] = [];
    
    for (let i = 0; i < convertResults.length; i++) {
      const result = convertResults[i];
      const imagePath = result.path;
      
      if (imagePath && fs.existsSync(imagePath)) {
        // Загружаем в Storage
        const fileName = `pdf-pages/${documentId}/page_${i + 1}.png`;
        const file = bucket.file(fileName);
        
        await file.save(fs.readFileSync(imagePath), {
          metadata: {
            contentType: 'image/png',
            cacheControl: 'public, max-age=31536000' // Кеш на год
          }
        });
        
        // Делаем файл публичным
        await file.makePublic();
        
        // Получаем публичный URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
        imageUrls.push(publicUrl);
        
        // Удаляем временный файл
        fs.unlinkSync(imagePath);
      }
    }
    
    // Удаляем временный PDF
    fs.unlinkSync(tempPdfPath);
    
    console.log(`✅ PDF converted successfully: ${imageUrls.length} pages`);
    
    return {
      success: true,
      pages: imageUrls.length,
      imageUrls: imageUrls
    };
    
  } catch (error) {
    console.error('❌ PDF conversion error:', error);
    const errorMessage = error instanceof Error ? error.message : String(error);
    throw new functions.https.HttpsError('internal', `Failed to convert PDF: ${errorMessage}`);
  }
});

/**
 * Получает уже сконвертированные изображения PDF по documentId
 */
export const getPdfImages = functions.https.onCall(async (data: any, context) => {
  try {
    const { documentId } = data as { documentId: string };
    
    if (!documentId) {
      throw new functions.https.HttpsError('invalid-argument', 'Document ID is required');
    }
    
    const bucket = getStorage().bucket();
    const [files] = await bucket.getFiles({
      prefix: `pdf-pages/${documentId}/`,
      delimiter: '/'
    });
    
    const imageUrls = files
      .filter(file => file.name.endsWith('.png'))
      .sort((a, b) => {
        // Сортируем по номеру страницы
        const pageA = parseInt(a.name.match(/page_(\d+)\.png/)?.[1] || '0');
        const pageB = parseInt(b.name.match(/page_(\d+)\.png/)?.[1] || '0');
        return pageA - pageB;
      })
      .map(file => `https://storage.googleapis.com/${bucket.name}/${file.name}`);
    
    return {
      success: true,
      pages: imageUrls.length,
      imageUrls: imageUrls
    };
    
  } catch (error) {
    console.error('❌ Get PDF images error:', error);
    const errorMessage = error instanceof Error ? error.message : String(error);
    throw new functions.https.HttpsError('internal', `Failed to get PDF images: ${errorMessage}`);
  }
}); 