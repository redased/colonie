# 📋 Plan d'Architecture - Application Colonie Vacances (VPS Hostinger)

## 🎯 **Objectif du Projet**

Développement d'une application Flutter de gestion de colonie de vacances avec 4 types d'utilisateurs :
- **Parent** (Accès gratuit)
- **Directeur** (Accès complet)
- **Animateur** (Gestion activités)
- **Comptable/Économe** (Gestion financière)

## 🏗️ **Architecture Technique**

### **Stack Recommandé**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   API RESTful    │    │   PostgreSQL    │
│  (Mobile App)   │◄──►│ (Node.js/Express)│◄──►│   (Base de     │
│                 │    │                  │    │   Données)      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                       ┌──────────────────┐
                       │  Stockage Fichiers│
                       │   (Images/PDFs)   │
                       └──────────────────┘
```

## 🖥️ **Infrastructure VPS Hostinger**

### **Configuration Suggérée**
- **OS**: Ubuntu 20.04 LTS ou 22.04 LTS
- **RAM**: 4GB minimum (8GB recommandé)
- **Stockage**: 80GB SSD
- **CPU**: 2+ cœurs
- **Bande passante**: Illimitée

### **Services à Installer**
```bash
# Services essentiels
- Docker & Docker Compose
- Nginx (Reverse Proxy)
- PostgreSQL 14+
- Node.js 18+ ou Python 3.9+
- Certbot (HTTPS gratuit)
- UFW (Firewall)
```

## 📱 **Application Flutter**

### **Structure Actuelle**
```
lib/
├── models/           # ✅ User, Child, Activity
├── services/         # 🔄 Modifier pour API REST
├── screens/          # ✅ Interfaces par type utilisateur
│   ├── auth/         # ✅ Splash, Login
│   ├── parent/       # ✅ Interface Parent
│   ├── director/     # ✅ Interface Directeur
│   ├── animator/     # ✅ Interface Animateur
│   └── accountant/   # ✅ Interface Comptable
├── widgets/          # ✅ Composants réutilisables
└── utils/            # ✅ AppColors, utilitaires
```

### **Modifications Nécessaires**
1. **Remacer Firebase Auth par JWT**
2. **Créer service API HTTP**
3. **Gestion tokens d'authentification**
4. **Upload/Download fichiers**

## 🗄️ **Base de Données PostgreSQL**

### **Structure des Tables Principales**

```sql
-- Utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) NOT NULL, -- parent, director, animator, accountant
    date_of_birth DATE,
    phone_number VARCHAR(20),
    profile_image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enfants
CREATE TABLE children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    blood_type VARCHAR(5),
    medical_conditions TEXT[],
    available_money DECIMAL(10,2) DEFAULT 0.00,
    group_id UUID REFERENCES groups(id),
    parent_phone_numbers TEXT[],
    profile_image_url TEXT,
    is_present BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Groupes
CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    animator_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activités
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    location VARCHAR(200),
    group_id UUID REFERENCES groups(id),
    animator_ids UUID[],
    child_ids UUID[],
    status VARCHAR(20) DEFAULT 'planned',
    image_url TEXT,
    required_materials TEXT[],
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Registres
CREATE TABLE registres (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL, -- presence, gold, import_export, meetings, visits
    title VARCHAR(200) NOT NULL,
    content TEXT,
    file_url TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions financières
CREATE TABLE financial_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(20) NOT NULL, -- expense, income
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relations Parent-Enfant
CREATE TABLE parent_children (
    parent_id UUID REFERENCES users(id),
    child_id UUID REFERENCES children(id),
    PRIMARY KEY (parent_id, child_id)
);
```

## 🔌 **API RESTful Backend**

### **Endpoints Principaux**

#### **Authentification**
```
POST /api/auth/login          # Connexion
POST /api/auth/register       # Inscription
POST /api/auth/refresh        # Rafraîchir token
POST /api/auth/logout         # Déconnexion
```

#### **Utilisateurs**
```
GET    /api/users             # Lister (admin seulement)
GET    /api/users/:id         # Détails utilisateur
PUT    /api/users/:id         # Mettre à jour profil
DELETE /api/users/:id         # Désactiver utilisateur
```

#### **Enfants**
```
GET    /api/children          # Lister (selon rôle)
POST   /api/children          # Créer enfant
GET    /api/children/:id      # Détails enfant
PUT    /api/children/:id      # Mettre à jour
DELETE /api/children/:id      # Supprimer
```

#### **Activités**
```
GET    /api/activities        # Lister activités
POST   /api/activities        # Créer activité
GET    /api/activities/:id    # Détails activité
PUT    /api/activities/:id    # Mettre à jour
DELETE /api/activities/:id    # Supprimer
```

#### **Fichiers**
```
POST   /api/upload/image      # Uploader image
POST   /api/upload/document   # Uploader document
GET    /api/files/:filename   # Télécharger fichier
```

### **Structure des Réponses API**

```json
{
  "success": true,
  "data": {
    // Données
  },
  "message": "Opération réussie",
  "timestamp": "2025-10-31T02:00:00Z"
}
```

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email invalide",
    "details": {}
  },
  "timestamp": "2025-10-31T02:00:00Z"
}
```

## 🔐 **Sécurité**

### **Authentification JWT**
```javascript
// Structure du token JWT
{
  "sub": "user_id",
  "email": "user@example.com",
  "userType": "parent",
  "iat": 1635724800,
  "exp": 1635728400
}
```

### **Mesures de Sécurité**
- **Password hashing** avec bcrypt
- **Rate limiting** sur endpoints sensibles
- **CORS** configuré pour domaines autorisés
- **HTTPS** avec Let's Encrypt
- **Validation stricte** des entrées
- **Logs d'activité** pour audit

## 📂 **Structure des Fichiers du Backend**

```
backend/
├── src/
│   ├── controllers/          # Logique métier
│   ├── models/              # Modèles de données
│   ├── routes/              # Routes API
│   ├── middleware/          # Auth, validation, etc.
│   ├── utils/               # Utilitaires
│   ├── config/              # Configuration DB, JWT
│   └── uploads/             # Fichiers uploadés
├── docker-compose.yml       # Configuration Docker
├── .env                     # Variables d'environnement
├── package.json             # Dépendances Node.js
└── Dockerfile              # Configuration container
```

## 🚀 **Déploiement avec Docker**

### **Docker Compose**
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/colonie_db
    depends_on:
      - db
    volumes:
      - ./uploads:/app/uploads

  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=colonie_db
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - app

volumes:
  postgres_data:
```

## 📊 **Monitoring et Maintenance**

### **Outils Recommandés**
- **Uptime monitoring** : UptimeRobot (gratuit)
- **Logs** : Winston + Papertrail
- **Backups** : Automatisés vers cloud storage
- **Performance** : PM2 pour Node.js
- **SSL** : Certbot + renouvellement automatique

### **Backup Strategy**
```bash
# Backup base de données quotidien
0 2 * * * pg_dump colonie_db > /backups/db_$(date +\%Y\%m\%d).sql

# Backup fichiers hebdomadaire
0 3 * * 0 tar -czf /backups/files_$(date +\%Y\%m\%d).tar.gz /app/uploads
```

## 💰 **Coûts Estimés**

### **VPS Hostinger**
- **VPS K2** : ~11€/mois (2GB RAM, 2 cores, 80GB SSD)
- **VPS K4** : ~22€/mois (8GB RAM, 4 cores, 160GB SSD) **Recommandé**

### **Services Additionnels**
- **Nom de domaine** : ~10€/an
- **Email professionnel** : ~5€/mois (optionnel)
- **Backup cloud** : ~5€/mois

**Total estimé** : ~30-40€/mois pour une solution robuste

## ✅ **Avantages vs Firebase**

| Critère | VPS Hostinger | Firebase |
|---------|--------------|----------|
| **Contrôle données** | ✅ Total | ❌ Google |
| **Scalabilité** | ✅ Illimitée | ⚠️ Coûteuse |
| **Coût prévisible** | ✅ Fixe | ❌ Variable |
| **Personnalisation** | ✅ Totale | ❌ Limitée |
| **Sécurité** | ✅ Maîtrisée | ⚠️ Dépendance |
| **Performance** | ✅ Optimisable | ⚠️ Quotas |

## 🎯 **Prochaines Étapes**

### **Phase 1: Setup VPS (1-2 jours)**
1. Configurer VPS Hostinger
2. Installer Docker et services
3. Mettre en place base de données
4. Configurer domaine et SSL

### **Phase 2: Backend API (3-5 jours)**
1. Créer structure projet
2. Implémenter authentification JWT
3. Développer endpoints CRUD
4. Ajouter upload de fichiers

### **Phase 3: Intégration Flutter (2-3 jours)**
1. Modifier services pour appeler API
2. Gérer tokens JWT
3. Adapter interface pour nouvelles données
4. Tests et corrections

### **Phase 4: Déploiement et Tests (1-2 jours)**
1. Déployer backend en production
2. Configurer monitoring
3. Tests avec utilisateurs réels
4. Documentation et formation

## 📈 **Évolution Future**

### **Fonctionnalités Avancées**
- **Notifications push** (OneSignal gratuit)
- **Chat interne** (WebSocket)
- **Géolocalisation temps réel** (GPS tracking)
- **Analytics et rapports** (Tableau de bord)
- **Module de facturation** (Paiements en ligne)
- **Application web** pour administrateurs

### **Scalabilité**
- **Load balancing** avec Nginx
- **Base de données répliquée**
- **CDN pour fichiers statiques**
- **Microservices** si nécessaire

---

**📝 Conclusion** : Le VPS Hostinger offre une solution professionnelle, économique et évolutive parfaitement adaptée aux besoins d'une application de gestion de colonie de vacances avec données sensibles.