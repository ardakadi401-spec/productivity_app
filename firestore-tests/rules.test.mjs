// FAZ 15 — firestore.rules doğrulaması. ROADMAP.md FAZ 15 "Riskler" bölümü:
// "Firebase Emulator Suite ile Rules'un otomatik test senaryolarıyla (hem
// 'izin verilmeli' hem 'izin verilmemeli' durumları) doğrulanması zorunlu
// kılınır." Bu dosya tam olarak bunu yapar — gerçek/production Firestore'a
// HİÇBİR ÇAĞRI yapmaz, yalnızca yerel emulator'e karşı çalışır.
//
// Çalıştırma: repo kökünden
//   firebase emulators:exec --project demo-productivity-app \
//     "cd firestore-tests && npm test"

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

const OWNER_UID = 'owner-uid';
const OTHER_UID = 'other-uid';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-productivity-app',
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

// DATABASE.md §1.2 "kullanıcı alt koleksiyonu modeli" gereği tek bir path
// deseni (users/{userId}/**) TÜM koleksiyonları temsil eder; her feature'ı
// ayrı ayrı test etmek yerine, kuralın kendisinin path-bazlı (feature-
// bağımsız) olduğunu birkaç temsili path üzerinden kanıtlamak yeterlidir.
const REPRESENTATIVE_PATHS = [
  { label: 'users/{uid} belgesi (Settings alanları)', path: (uid) => `users/${uid}` },
  { label: 'projects/{id}', path: (uid) => `users/${uid}/projects/p1` },
  { label: 'tasks/{id}', path: (uid) => `users/${uid}/tasks/t1` },
  { label: 'tasks/{id}/subtasks/{id} (nested alt koleksiyon)', path: (uid) => `users/${uid}/tasks/t1/subtasks/s1` },
  { label: 'habits/{id}', path: (uid) => `users/${uid}/habits/h1` },
  { label: 'habits/{id}/habitRecords/{id} (nested alt koleksiyon)', path: (uid) => `users/${uid}/habits/h1/habitRecords/2026-01-01` },
  { label: 'statisticsSnapshots/{id}', path: (uid) => `users/${uid}/statisticsSnapshots/2026-01-01` },
];

describe('firestore.rules — kimlik doğrulama olmadan erişim', () => {
  for (const { label, path } of REPRESENTATIVE_PATHS) {
    test(`${label}: auth yoksa okuma REDDEDİLİR`, async () => {
      const unauth = testEnv.unauthenticatedContext();
      await assertFails(getDoc(doc(unauth.firestore(), path(OWNER_UID))));
    });

    test(`${label}: auth yoksa yazma REDDEDİLİR`, async () => {
      const unauth = testEnv.unauthenticatedContext();
      await assertFails(setDoc(doc(unauth.firestore(), path(OWNER_UID)), { x: 1 }));
    });
  }
});

describe('firestore.rules — başka kullanıcının verisine erişim', () => {
  for (const { label, path } of REPRESENTATIVE_PATHS) {
    test(`${label}: farklı kullanıcı okuyamaz (cross-user izolasyon)`, async () => {
      const asOther = testEnv.authenticatedContext(OTHER_UID);
      await assertFails(getDoc(doc(asOther.firestore(), path(OWNER_UID))));
    });

    test(`${label}: farklı kullanıcı yazamaz (cross-user izolasyon)`, async () => {
      const asOther = testEnv.authenticatedContext(OTHER_UID);
      await assertFails(setDoc(doc(asOther.firestore(), path(OWNER_UID)), { x: 1 }));
    });
  }
});

describe('firestore.rules — kendi verisine erişim', () => {
  for (const { label, path } of REPRESENTATIVE_PATHS) {
    test(`${label}: sahibi yazabilir ve okuyabilir`, async () => {
      const asOwner = testEnv.authenticatedContext(OWNER_UID);
      await assertSucceeds(setDoc(doc(asOwner.firestore(), path(OWNER_UID)), { x: 1 }));
      const snapshot = await assertSucceeds(getDoc(doc(asOwner.firestore(), path(OWNER_UID))));
      assert.equal(snapshot.data().x, 1);
    });
  }
});
