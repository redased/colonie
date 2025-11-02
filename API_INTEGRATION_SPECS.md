# 🔌 API Integration Specifications - Colonie Vacances

## 📡 **Configuration API**

### **Base URL**
```
Développement: http://72.61.161.87:8080
Production: https://api.votredomaine.com (future)
```

### **Health Check**
```
GET /api/health
```

## 🔐 **Flux d'Authentification**

### **Inscription**
```
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123", // min 8 caractères
  "firstName": "Jean",
  "lastName": "Dupont",
  "userType": "parent" // parent, director, animator, accountant
}
```

### **Connexion**
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "firstName": "Jean",
      "lastName": "Dupont",
      "userType": "parent"
    }
  }
}
```

### **Rafraîchissement Token**
```
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

### **Déconnexion**
```
POST /api/auth/logout
Authorization: Bearer <accessToken>
```

## 📋 **Endpoints Principaux**

### **Utilisateurs (/api/users)**
```
GET    /api/users              # Liste (directeur seulement)
GET    /api/users/:id          # Profil utilisateur
PUT    /api/users/:id          # Update (directeur ou self)
DELETE /api/users/:id          # Désactivation (directeur)
```

### **Enfants (/api/children)**
```
GET    /api/children           # Liste filtrée par rôle
POST   /api/children           # Créer (directeur)
GET    /api/children/:id       # Détails enfant
PUT    /api/children/:id       # Update (directeur)
DELETE /api/children/:id       # Supprimer (directeur)
```

**Champs Enfant:**
```json
{
  "firstName": "Pierre",
  "lastName": "Martin",
  "dateDeNaissance": "2015-06-15",
  "groupe": "uuid_groupe",
  "parents": ["uuid_parent1", "uuid_parent2"],
  "medicalConditions": [],
  "availableMoney": 150.00
}
```

### **Activités (/api/activities)**
```
GET    /api/activities         # Liste (filtrée par groupe)
POST   /api/activities         # Créer (directeur/animateur)
GET    /api/activities/:id     # Détails activité
PUT    /api/activities/:id     # Update (directeur/animateur)
DELETE /api/activities/:id     # Supprimer (directeur)
```

**Champs Activité:**
```json
{
  "title": "Jeux de piste",
  "description": "Grande chasse au trésor dans la forêt",
  "dates": {
    "debut": "2025-07-15T09:00:00.000Z",
    "fin": "2025-07-15T12:00:00.000Z"
  },
  "participants": ["uuid_enfant1", "uuid_enfant2"],
  "groupe": "uuid_groupe"
}
```

### **Fichiers (/api/files)**
```
POST   /api/files/upload/image     # Upload image (≤5Mo)
POST   /api/files/upload/document  # Upload document (≤10Mo)
GET    /api/files/:filename        # Télécharger fichier
```

**Formats acceptés:**
- **Images**: PNG, JPEG, WebP (≤5Mo)
- **Documents**: PDF, DOC, DOCX, XLS, XLSX, TXT (≤10Mo)

## 📊 **Format des Réponses**

### **Succès**
```json
{
  "success": true,
  "data": {
    // Données spécifiques
  },
  "message": "Opération réussie",
  "timestamp": "2025-02-17T12:00:00.000Z"
}
```

### **Erreur**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email invalide",
    "details": {
      "field": "email",
      "value": "invalid-email"
    }
  },
  "timestamp": "2025-02-17T12:00:00.000Z"
}
```

## 🔐 **Sécurité**

### **Headers Obligatoires**
```
Authorization: Bearer <accessToken>
Content-Type: application/json (pour POST/PUT)
```

### **Tokens**
- **AccessToken**: TTL 15 minutes
- **RefreshToken**: TTL 7 jours
- **Champs sensibles**: Jamais exposés (passwordHash, tokens filtrés par API)

## 📱 **Prérequis Flutter**

### **Gestion des Tokens**
- Stockage sécurisé (SharedPreferences + encryption)
- Refresh automatique avant expiration
- Gestion du 401 (redirection vers login)

### **Services HTTP**
- Intercepteur pour ajouter Authorization header
- Gestion automatique du refresh token
- Mapping JSON snake_case ↔ camelCase

### **Upload Fichiers**
- Requêtes multipart/form-data
- Validation taille avant upload
- Progress indicator pour gros fichiers

### **Mapping des Rôles**
```dart
enum UserType {
  parent,     // Accès limité enfant(s)
  director,   // Accès complet
  animator,   // Gestion activités/groupe
  accountant  // Tableau financier
}
```

## 🧪 **Tests à Effectuer**

1. **Authentification**
   - [ ] Inscription avec validation email
   - [ ] Login avec mauvais mot de passe
   - [ ] Refresh token automatique
   - [ ] Déconnexion

2. **Accès par Rôle**
   - [ ] Parent: voit seulement ses enfants
   - [ ] Directeur: accès complet
   - [ ] Animateur: voit son groupe
   - [ ] Comptable: accès finances

3. **Upload Fichiers**
   - [ ] Image PNG/JPEG valide
   - [ ] Document PDF valide
   - [ ] Erreur taille dépassée
   - [ ] Erreur format invalide

4. **Gestion Erreurs**
   - [ ] 401 Unauthorized (token expiré)
   - [ ] 403 Forbidden (droits insuffisants)
   - [ ] 404 Not Found (ressource inexistante)
   - [ ] 500 Server Error (problème backend)

## 📝 **Notes Techniques**

- **Format dates**: ISO8601 (`2025-02-17T12:00:00.000Z`)
- **Rate limiting**: À prévoir (limites non encore définies)
- **JSON**: Backend snake_case → Flutter camelCase
- **HTTPS**: Obligatoire en production
- **Timeout**: 30 secondes par défaut

---
**Prêt pour intégration Flutter !** 🚀