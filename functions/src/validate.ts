import * as querystring from 'querystring';
import * as crypto from 'crypto';

export function checkWebAppSignature(initData: string, secretKeyHex: string): false | number {
    console.log('Raw initData received:', initData);
    const parsed = querystring.parse(initData);
    console.log('Parsed by querystring:', JSON.stringify(parsed, null, 2));
    
    const parsedData = convertParsedData(parsed);
    console.log('Converted parsed data:', JSON.stringify(parsedData, null, 2));
    if (!parsedData) return false;

    const { hash, ...rest } = parsedData;
    if (!hash) return false;

    const dataCheckString = Object.entries(rest)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([key, value]) => `${key}=${value}`)
        .join('\n');

    console.log('DataCheckString:', dataCheckString);
    console.log('User field:', rest['user']);

    // Безопасно парсим user данные
    let uid: number;
    try {
        if (!rest['user']) {
            console.error('User field is missing from initData');
            return false;
        }
        const userStr = rest['user'];
        if (userStr === 'undefined' || userStr === 'null') {
            console.error('User field is undefined or null');
            return false;
        }
        const userData = JSON.parse(userStr);
        uid = userData['id'];
        if (!uid) {
            console.error('User ID is missing from user data');
            return false;
        }
        console.log('Extracted user ID:', uid);
    } catch (error) {
        console.error('Error parsing user data:', error);
        console.error('User field value:', rest['user']);
        return false;
    }

    const secretKey = Buffer.from(secretKeyHex, 'hex');
    const calculatedHash = crypto.createHmac('sha256', secretKey)
        .update(dataCheckString)
        .digest('hex');

    if (calculatedHash === hash) return uid;
    return false;
}

function convertParsedData(parsedData: querystring.ParsedUrlQuery): { [key: string]: string } | null {
    const result: { [key: string]: string } = {};
    for (const key in parsedData) {
        const value = parsedData[key];
        if (Array.isArray(value)) {
            result[key] = value.join(',');
        } else if (typeof value === 'string') {
            result[key] = value;
        } else {
            return null;
        }
    }
    return result;
}