# ==============================================
# 🚀 Makefile Maestro - Docker Monorepo SIB-CR
# ==============================================

# ==============================================
# 🧱 VARIABLES
# ==============================================

COMPOSE_PROD := docker-compose.prod.yml
ENV_PROD     := .env.prod
DOCKER_USER  := lpcodeadmin
TAG          := latest

# ==============================================
# 📦 SERVICIOS (Definidos en docker-compose.prod.yml)
# ==============================================

BACKEND_SERVICE := backend
ADMIN_SERVICE   := admin
PUBLIC_SERVICE  := publico
DB_SERVICE      := db

# ==============================================
# 🐳 CONTENEDORES (Nombres fijos para comandos directos de Docker)
# ==============================================

BACKEND_CONTAINER := sib-cr-backend-prod
DB_CONTAINER      := sib-cr-database-prod
ADMIN_CONTAINER   := sib_cr_frontend_admin_prod
PUBLIC_CONTAINER  := sib_cr_frontend_publico_prod

# ==============================================
# 🎨 COLORES
# ==============================================

GREEN   := \033[0;32m
YELLOW  := \033[1;33m
BLUE    := \033[1;34m
RED     := \033[1;31m
RESET   := \033[0m

.DEFAULT_GOAL := help

# ==============================================
# 🔐 CARGAR VARIABLES .ENV
# Incluimos las variables del .env para que estén disponibles en los comandos
# ==============================================

ifneq ("$(wildcard $(ENV_PROD))","")
    include $(ENV_PROD)
    export $(shell sed 's/=.*//' $(ENV_PROD))
endif

# ==============================================
# 🚀 DESPLIEGUE Y ACTUALIZACIÓN
# ==============================================

# 🚀 Levanta todo el sistema en producción
prod:
	@echo "$(BLUE)🏗️ Iniciando despliegue en entorno de producción...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) --env-file $(ENV_PROD) up -d
	@echo "$(GREEN)✨ ¡Sistema levantado exitosamente!$(RESET)"
	@echo "$(YELLOW)Admin: $(ADMIN_URL)$(RESET)"
	@echo "$(YELLOW)Público: $(PUBLIC_URL)$(RESET)"

# 🏗️ Reconstruir y levantar todo el sistema de producción
prod-build:
	@echo "$(BLUE)🏗️ Rebuild completo de producción...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) --env-file $(ENV_PROD) up -d --build
	@echo "$(GREEN)✅ Build y despliegue completados$(RESET)"

# ==============================================
# 🔄 REINICIAR SERVICIOS
# ==============================================

# Reinicia todos los servicios
restart:
	@echo "$(BLUE)🔄 Reiniciando servicios...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) restart

# Reinicia backend
restart-backend:
	@echo "$(BLUE)🔄 Reiniciando Backend...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) restart $(BACKEND_SERVICE)

# Reiniciar base de datos
restart-db:
	@echo "$(BLUE)🔄 Reiniciando Base de Datos...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) restart $(DB_SERVICE)

# Reiniciar frontend admin
restart-admin:
	@echo "$(BLUE)🔄 Reiniciando Frontend Admin...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) restart $(ADMIN_SERVICE)

# Reiniciar frontend publico
restart-public:
	@echo "$(BLUE)🔄 Reiniciando Frontend Público...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) restart $(PUBLIC_SERVICE)

# ==============================================
# 🔄 ACTUALIZAR SERVICIOS ATÓMICAS (Sin caída de otros servicios)
# ==============================================

# Actualizar todos los servicios
update-all:
	@echo "$(BLUE)🚀 Actualizando todos los servicios...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) pull
	@docker compose -f $(COMPOSE_PROD) up -d
	@echo "$(GREEN)✅ Todos los servicios actualizados$(RESET)"

# Actualizar Backend
update-backend:
	@echo "$(BLUE)🚀 Actualizando Backend...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) pull $(BACKEND_SERVICE)
	@docker compose -f $(COMPOSE_PROD) up -d --no-deps $(BACKEND_SERVICE)
	@echo "$(GREEN)✅ Backend actualizado$(RESET)"

# Actualizar Frontend Admin
update-admin:
	@echo "$(BLUE)🚀 Actualizando Frontend Admin...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) pull $(ADMIN_SERVICE)
	@docker compose -f $(COMPOSE_PROD) up -d --no-deps $(ADMIN_SERVICE)
	@echo "$(GREEN)✅ Frontend Admin actualizado$(RESET)"

# Actualizar Frontend Público
update-public:
	@echo "$(BLUE)🚀 Actualizando Frontend Público...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) pull $(PUBLIC_SERVICE)
	@docker compose -f $(COMPOSE_PROD) up -d --no-deps $(PUBLIC_SERVICE)
	@echo "$(GREEN)✅ Frontend Público actualizado$(RESET)"

# ==============================================
# 🛑 APAGADO Y LIMPIEZA
# ==============================================

# Detiene y elimina contenedores y redes
down-all:
	@echo "$(RED)🗑️ Deteniendo y eliminando contenedores del sistema...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) down

## Detiene y elimina volúmenes (¡BORRA DATOS!)
down-volumes: 
	@echo "$(RED)⚠️ Eliminando contenedores y volúmenes...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) down -v

## Limpieza segura de imágenes huérfanas
clean-images: 
	@echo "$(BLUE)🧹 Limpiando imágenes no utilizadas...$(RESET)"
	@docker image prune -f

# Limpieza segura de volúmenes no utilizados
prune:
	@echo "$(BLUE)🧹 Limpieza segura Docker...$(RESET)"
	@docker system prune -f

# Eliminar redes no utilizadas
network-prune:
	@echo "$(BLUE)🌐 Eliminando redes no utilizadas...$(RESET)"
	@docker network prune -f

# 🧼 Limpieza Profunda (Contenedores, Imágenes y Volúmenes)
# ¡CUIDADO! Esto borrará la base de datos si no haces backup
clean-danger: 
	@echo "$(RED)⚠️ ADVERTENCIA: Se eliminarán todos los datos y cachés.$(RESET)"
	@read -p "¿Estás seguro? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		docker compose -f $(COMPOSE_PROD) down -v --rmi all; \
		docker system prune -a --volumes -f; \
		echo "$(GREEN)✅ Sistema reseteado a cero.$(RESET)"; \
	else \
		echo "$(YELLOW)❌ Operación cancelada.$(RESET)"; \
	fi

# ==============================================
# 📊 MONITOREO Y LOGS
# ==============================================

## Ver estado de los contenedores
status: 
	@docker compose -f $(COMPOSE_PROD) ps

## Ver consumo de CPU y RAM en tiempo real
stats: 
	@docker stats

## Logs del Backend
logs-backend: 
	@docker logs -f $(BACKEND_CONTAINER)

## Logs de la Base de Datos
logs-db: 
	@docker logs -f $(DB_CONTAINER)

## Logs del Frontend Admin
logs-admin: 
	@docker logs -f $(ADMIN_CONTAINER)

## Logs del Frontend Público
logs-public: 
	@docker logs -f $(PUBLIC_CONTAINER)

## Logs de todos los servicios
logs-all: 
	@docker compose -f $(COMPOSE_PROD) logs -f

## Inspeccionar contenedor de Backend
inspect-backend:
	@docker inspect $(BACKEND_CONTAINER)

## Inspeccionar contenedor de Base de Datos
inspect-db:
	@docker inspect $(DB_CONTAINER)

# Inspeccionar contenedor de Frontend Admin
inspect-admin:
	@docker inspect $(ADMIN_CONTAINER)

# Inspeccionar contenedor de Frontend Público
inspect-public:
	@docker inspect $(PUBLIC_CONTAINER)

# Ver configuración de los servicios
config:
	@docker compose -f $(COMPOSE_PROD) config

# Validar docker-compose
validate:
	@echo "$(BLUE)🔎 Validando docker-compose...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) config > /dev/null && echo "$(GREEN)✅ docker-compose válido$(RESET)"

# ==============================================
# 🐘 BASE DE DATOS (PostgreSQL)
# ==============================================

# Entrar a la terminal de PostgreSQL
db-shell: 
	@docker exec -it $(DB_CONTAINER) psql -U $(DATASOURCE_USERNAME) -d $(DATASOURCE_DB_NAME)

# Generar backup .sql (Usa variables del .env)
db-dump1:
	@echo "$(BLUE)💾 Generando backup...$(RESET)"
	@export $$(grep -v '^#' $(ENV_PROD) | xargs) && \
	docker exec $(DB_CONTAINER) pg_dump -U $$DATASOURCE_USERNAME $$DATASOURCE_DB_NAME > backup_$$(date +%F_%H-%M-%S).sql
	@echo "$(GREEN)✅ Backup generado$(RESET)"

## Generar backup .sql (Usa variables del .env)
db-dump2: 
	@echo "$(BLUE)💾 Generando backup de $(DATASOURCE_DB_NAME)...$(RESET)"
	@docker exec $(DB_CONTAINER) pg_dump -U $(DATASOURCE_USERNAME) $(DATASOURCE_DB_NAME) > backup_$$(date +%F_%H-%M).sql
	@echo "$(GREEN)✅ Backup creado: backup_$$(date +%F_%H-%M).sql$(RESET)"

## Listar volúmenes
volume-ls: 
	@docker volume ls

## Inspeccionar un volúmen
volume-inspect:
	@docker volume inspect sib_db_data

import-obras:
	@echo "$(BLUE)📂 Usando archivo: $(OBRAS_CSV)$(RESET)"
	@echo "$(BLUE)📤 Copiando CSV al contenedor...$(RESET)"
	docker cp ./$(OBRAS_CSV) sib-cr-database-prod:/tmp/obras_final.csv
	
	@echo "$(BLUE)🚀 Iniciando importación SQL...$(RESET)"
	docker exec -it sib-cr-database-prod psql -U $(DATASOURCE_USERNAME) -d $(DATASOURCE_DB_NAME) -c "\
		SET datestyle TO 'ISO, DMY'; \
		TRUNCATE public.obras RESTART IDENTITY CASCADE; \
		COPY public.obras (agency, description, municipality, name, investment, status, latitude, longitude, created_by_id, updated_by_id, created_at, updated_at, deleted, progress) \
		FROM '/tmp/obras_final.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8'); \
		UPDATE obras SET created_by_id = (SELECT id_user FROM users ORDER BY id_user ASC LIMIT 1), \
		                 updated_by_id = (SELECT id_user FROM users ORDER BY id_user ASC LIMIT 1); \
		SELECT setval(pg_get_serial_sequence('obras', 'id'), coalesce(max(id), 1)) FROM obras;"
	
	@echo "$(GREEN)✅ Proceso completado.$(RESET)"

clean-temp:
	@echo "$(BLUE)🧹 Limpiando archivos temporales...$(RESET)"
		docker exec -it sib-cr-database-prod rm /tmp/obras_final.csv

# ==============================================
# 🌐 REDES Y DIAGNÓSTICO
# ==============================================

# Listar redes de Docker
networks-ls: 
	@docker network ls

# Inspeccionar una red
network-inspect:
	@read -p "Nombre de la red: " net; \
	docker network inspect $$net

# Probar si el Backend llega a la DB
ping-db: 
	@echo "$(BLUE)🔎 Probando conexión Backend -> DB...$(RESET)"
	@docker exec -it $(BACKEND_CONTAINER) ping db -c 3

# Probar si el Admin llega al Backend
ping-backend:
	@docker exec -it $(ADMIN_CONTAINER) ping backend

# Probar si el Público llega al Backend
ping-public:
	@docker exec -it $(PUBLIC_CONTAINER) ping backend

# ==============================================
# 🏭 CONSTRUCCIÓN (Solo construir para pruebas locales) (CI/CD Local)
# ==============================================

build-local: build-backend-local build-admin-local build-public-local
	@echo "$(GREEN)✅ Imágenes construidas localmente. Listas para 'make prod'$(RESET)"

build-backend-local:
	docker build -t $(DOCKER_USER)/sib-backend:$(TAG) ./Backend

build-admin-local:
	docker build --target prod \
		--build-arg VITE_API_URL=$(URL_BASE_API_BACKEND) \
		-t $(DOCKER_USER)/sib-frontend-admin:$(TAG) ./Frontend-Admin

build-public-local:
	docker build --target prod \
		--build-arg VITE_API_URL=$(URL_BASE_API_BACKEND) \
		-t $(DOCKER_USER)/sib-frontend-publico:$(TAG) ./Frontend-Public


# ==============================================
# 🏭 COMANDOS DE FÁBRICA (Para constuir y enviar a docker hub)
# ==============================================

# Construir y subir todas las imágenes
build-and-push: build-backend build-admin build-public
	@echo "$(GREEN)🚀 ¡Todas las imágenes han sido enviadas a Docker Hub!$(RESET)"

# Construir y subir Backend
build-backend:
	@echo "$(BLUE)📦 Construyendo Backend...$(RESET)"
	docker build -t $(DOCKER_USER)/sib-backend:$(TAG) ./Backend
	docker push $(DOCKER_USER)/sib-backend:$(TAG)

# Construir y subir Frontend Admin
build-admin:
	@echo "$(BLUE)📦 Construyendo Frontend Admin...$(RESET)"
	docker build --target prod \
		--build-arg VITE_API_URL=$(URL_BASE_API_BACKEND) \
		-t $(DOCKER_USER)/sib-frontend-admin:$(TAG) ./Frontend-Admin
	docker push $(DOCKER_USER)/sib-frontend-admin:$(TAG)

# Construir y subir Frontend Público
build-public:
	@echo "$(BLUE)📦 Construyendo Frontend Público con API: $(URL_BASE_API_BACKEND)...$(RESET)"
	docker build --target prod \
		--build-arg VITE_API_URL=$(URL_BASE_API_BACKEND) \
		-t $(DOCKER_USER)/sib-frontend-publico:$(TAG) ./Frontend-Public
	docker push $(DOCKER_USER)/sib-frontend-publico:$(TAG)

# ==============================================
# 📘 HELP
# ==============================================

help:
	@echo ""
	@echo "$(GREEN)==============================================$(RESET)"
	@echo "$(GREEN)🚀 MAKEFILE MAESTRO - SIB-CR$(RESET)"
	@echo "$(GREEN)==============================================$(RESET)"
	@echo ""

	@echo "$(YELLOW)🚀 DESPLIEGUE Y ACTUALIZACIÓN$(RESET)"
	@echo "  make prod               → Levantar entorno productivo"
	@echo "  make prod-build         → Rebuild completo y despliegue"
	@echo "  make update-all         → Actualizar todos los servicios"
	@echo "  make update-backend     → Actualizar Backend"
	@echo "  make update-admin       → Actualizar Frontend Admin"
	@echo "  make update-public      → Actualizar Frontend Público"
	@echo ""

	@echo "$(YELLOW)🔄 REINICIO DE SERVICIOS$(RESET)"
	@echo "  make restart            → Reiniciar todos los servicios"
	@echo "  make restart-backend    → Reiniciar Backend"
	@echo "  make restart-db         → Reiniciar PostgreSQL"
	@echo "  make restart-admin      → Reiniciar Frontend Admin"
	@echo "  make restart-public     → Reiniciar Frontend Público"
	@echo ""

	@echo "$(YELLOW)📊 MONITOREO Y LOGS$(RESET)"
	@echo "  make status             → Estado de contenedores"
	@echo "  make stats              → Consumo CPU/RAM"
	@echo "  make logs-backend       → Logs Backend"
	@echo "  make logs-db            → Logs PostgreSQL"
	@echo "  make logs-admin         → Logs Frontend Admin"
	@echo "  make logs-public        → Logs Frontend Público"
	@echo "  make logs-all           → Logs de todos los servicios"
	@echo ""

	@echo "$(YELLOW)🔍 INSPECCIÓN Y VALIDACIÓN$(RESET)"
	@echo "  make inspect-backend    → Inspeccionar Backend"
	@echo "  make inspect-db         → Inspeccionar PostgreSQL"
	@echo "  make inspect-admin      → Inspeccionar Frontend Admin"
	@echo "  make inspect-public     → Inspeccionar Frontend Público"
	@echo "  make config             → Mostrar compose final"
	@echo "  make validate           → Validar docker-compose"
	@echo ""

	@echo "$(YELLOW)🐘 BASE DE DATOS$(RESET)"
	@echo "  make db-shell           → Entrar a PostgreSQL"
	@echo "  make db-dump1           → Backup PostgreSQL (.sql)"
	@echo "  make db-dump2           → Backup PostgreSQL alternativo"
	@echo "  make volume-ls          → Listar volúmenes"
	@echo "  make volume-inspect     → Inspeccionar volumen DB"
	@echo "  make import-obras       → Importar obras desde CSV"
	@echo "  make clean-temp         → Limpiar archivos temporales"
	@echo ""

	@echo "$(YELLOW)🌐 REDES Y DIAGNÓSTICO$(RESET)"
	@echo "  make networks-ls        → Listar redes Docker"
	@echo "  make network-inspect    → Inspeccionar red"
	@echo "  make ping-db            → Backend → PostgreSQL"
	@echo "  make ping-backend       → Admin → Backend"
	@echo "  make ping-public        → Público → Backend"
	@echo ""

	@echo "$(YELLOW)🧹 LIMPIEZA Y MANTENIMIENTO$(RESET)"
	@echo "  make down-all           → Detener entorno"
	@echo "  make down-volumes       → Eliminar contenedores + volúmenes"
	@echo "  make clean-images       → Limpiar imágenes huérfanas"
	@echo "  make prune              → Limpieza segura Docker"
	@echo "  make network-prune      → Limpiar redes Docker"
	@echo "  make clean-danger       → RESET TOTAL del sistema"
	@echo ""

	@echo "$(YELLOW)🏭 BUILD Y DOCKER HUB$(RESET)"
	@echo "  make build-backend      → Build Backend"
	@echo "  make build-admin        → Build Frontend Admin"
	@echo "  make build-public       → Build Frontend Público"
	@echo "  make build-and-push     → Build y Push de todas las imágenes"
	@echo ""

	@echo "$(YELLOW)🏭 BUILD Y LOCAL$(RESET)"
	@echo "  make build-local              → Build Backend + Frontend Admin + Frontend Público Localmente"
	@echo "  make build-backend-local      → Build Backend Localmente"
	@echo "  make build-admin-local        → Build Frontend Admin Localmente"
	@echo "  make build-public-local       → Build Frontend Público Localmente"
	@echo ""

	@echo "-----------------------------------------------"