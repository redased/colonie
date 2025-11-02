# 🗄️ Configuration Base de Données PostgreSQL

## 📋 **Informations de Connexion**

### **🔧 Environnement Développement (Docker)**
```
Host: db (interne) / 127.0.0.1 (externe si mapping)
Port: 5432
Base de données: colonie_db
Utilisateur: colonie_user
Mot de passe: colonie_pass
```

### **🌐 URL de Connexion**
```
DATABASE_URL=postgresql://colonie_user:colonie_pass@db:5432/colonie_db
```

## 🐳 **Configuration Docker Compose**

Les identifiants sont définis dans `docker-compose.yml:18` et appliqués automatiquement à l'API via `DATABASE_URL`.

## 📊 **Structure de la Base de Données**

### **Tables Principales**

#### **users**
```sql
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
```

#### **children**
```sql
CREATE TABLE children (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_de_naissance DATE NOT NULL,
    groupe UUID REFERENCES groups(id),
    parents TEXT[], -- Array de UUIDs
    medical_conditions TEXT[],
    available_money DECIMAL(10,2) DEFAULT 0.00,
    profile_image_url TEXT,
    is_present BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **activities**
```sql
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    dates JSONB NOT NULL, -- {"debut": "2025-07-15T09:00:00Z", "fin": "2025-07-15T12:00:00Z"}
    location VARCHAR(200),
    groupe UUID REFERENCES groups(id),
    participants TEXT[], -- Array de UUIDs enfants
    animator_ids TEXT[], -- Array de UUIDs animateurs
    status VARCHAR(20) DEFAULT 'planned', -- planned, inProgress, completed, cancelled
    image_url TEXT,
    required_materials TEXT[],
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **groups**
```sql
CREATE TABLE groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    animator_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **registres**
```sql
CREATE TABLE registres (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL, -- presence, gold, import_export, meetings, visits
    title VARCHAR(200) NOT NULL,
    content TEXT,
    file_url TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **financial_transactions**
```sql
CREATE TABLE financial_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(20) NOT NULL, -- expense, income
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **parent_children (Table de liaison)**
```sql
CREATE TABLE parent_children (
    parent_id UUID REFERENCES users(id),
    child_id UUID REFERENCES children(id),
    PRIMARY KEY (parent_id, child_id)
);
```

## 🔗 **Relations entre Tables**

```
users (1) ←→ (N) parent_children (N) ←→ (1) children
users (1) ←→ (N) activities (animator_ids)
groups (1) ←→ (N) children
groups (1) ←→ (N) activities
users (1) ←→ (1) groups (animator_id)
users (1) ←→ (N) registres
users (1) ←→ (N) financial_transactions
```

## 🚀 **Configuration Production**

### **⚠️ Sécurité**
- En production, utiliser des secrets plus robustes
- Définir variables d'environnement `.env`
- Exposer port 5432 uniquement si nécessaire

### **🔐 Variables d'Environnement Recommandées**
```bash
# .env.production
POSTGRES_DB=colonie_db_prod
POSTGRES_USER=colonie_user_prod
POSTGRES_PASSWORD=GENERATED_STRONG_PASSWORD
POSTGRES_HOST=db
POSTGRES_PORT=5432
```

### **🌐 Exposition Port (si nécessaire)**
Dans `docker-compose.yml`:
```yaml
services:
  db:
    # ... autres configurations
    ports:
      - "5432:5432"  # Expose port externe (attention sécurité)
```

## 📈 **Performance et Indexation**

### **Indexes Recommandés**
```sql
-- Index pour performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_children_groupe ON children(groupe);
CREATE INDEX idx_activities_dates ON activities USING GIN(dates);
CREATE INDEX idx_activities_groupe ON activities(groupe);
CREATE INDEX idx_financial_transactions_type ON financial_transactions(type);
CREATE INDEX idx_registres_type ON registres(type);
```

## 🔍 **Requêtes Utiles**

### **Vérifier Connexion**
```sql
-- Test connexion
SELECT current_database(), current_user;

-- Lister tables
\dt

-- Structure table
\d users
\d children
\d activities
```

### **Stats Base de Données**
```sql
-- Nombre d'utilisateurs par type
SELECT user_type, COUNT(*) FROM users GROUP BY user_type;

-- Enfants par groupe
SELECT g.name, COUNT(c.id) as children_count
FROM groups g LEFT JOIN children c ON g.id = c.groupe
GROUP BY g.id, g.name;

-- Activités par statut
SELECT status, COUNT(*) FROM activities GROUP BY status;
```

---
**Note**: Ces identifiants sont pour l'environnement de développement. En production, utilisez des secrets robustes ! 🔐