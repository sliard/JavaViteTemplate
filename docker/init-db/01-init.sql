-- Script d'initialisation de la base de données
-- Ce fichier est exécuté automatiquement au premier démarrage de PostgreSQL

-- Créer des extensions utiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Note: Les tables seront créées par Hibernate/JPA au démarrage de l'application
-- Ce fichier peut être utilisé pour :
--   - Créer des données initiales (utilisateur admin, configuration, etc.)
--   - Ajouter des index personnalisés
--   - Configurer des permissions spécifiques

-- Exemple de création d'un utilisateur admin (à décommenter et adapter)
-- INSERT INTO users (id, email, password, role, created_at)
-- VALUES (
--     uuid_generate_v4(),
--     'admin@example.com',
--     crypt('changeme', gen_salt('bf')),
--     'ADMIN',
--     NOW()
-- ) ON CONFLICT DO NOTHING;

