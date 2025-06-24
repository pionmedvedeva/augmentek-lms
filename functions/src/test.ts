import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getAuth } from 'firebase-admin/auth';

const app = initializeApp();
const db = getFirestore(app);
const auth = getAuth(app);

export async function testCreateAdminDocument() {
  try {
    // Находим пользователя с isAdmin: true
    const usersSnapshot = await db.collection('users').where('isAdmin', '==', true).get();
    
    if (usersSnapshot.empty) {
      console.log('❌ No admin users found');
      return;
    }

    const adminUser = usersSnapshot.docs[0].data();
    const telegramId = adminUser.id;
    
    console.log('👤 Found admin user:', {
      id: telegramId,
      firstName: adminUser.firstName,
      firebaseId: adminUser.firebaseId
    });

    // Создаем пользователя в Firebase Auth если его нет
    let firebaseUid = adminUser.firebaseId;
    
    if (!firebaseUid) {
      console.log('🔐 Creating Firebase Auth user...');
      
      const userRecord = await auth.createUser({
        uid: `telegram_${telegramId}`,
        displayName: `${adminUser.firstName} ${adminUser.lastName || ''}`.trim(),
      });
      
      firebaseUid = userRecord.uid;
      console.log('✅ Firebase Auth user created:', firebaseUid);
      
      // Обновляем документ пользователя с firebaseId
      await db.collection('users').doc(telegramId.toString()).update({
        firebaseId: firebaseUid
      });
      
      console.log('✅ User document updated with firebaseId');
    }

    // Создаем документ в коллекции admins
    const adminDocRef = db.collection('admins').doc(firebaseUid);
    const adminDocSnap = await adminDocRef.get();
    
    if (!adminDocSnap.exists) {
      await adminDocRef.set({
        telegramId: telegramId,
        createdAt: new Date().toISOString(),
      });
      console.log('✅ Admin document created in admins collection');
    } else {
      console.log('✅ Admin document already exists');
    }
    
    // Проверяем что все работает
    const testDocSnap = await adminDocRef.get();
    if (testDocSnap.exists) {
      console.log('✅ Admin document verification successful:', testDocSnap.data());
    } else {
      console.log('❌ Admin document verification failed');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

// Запускаем тест если файл вызван напрямую
if (require.main === module) {
  testCreateAdminDocument().then(() => {
    console.log('Test completed');
    process.exit(0);
  }).catch((error) => {
    console.error('Test failed:', error);
    process.exit(1);
  });
} 