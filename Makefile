# ==============================================
# 🚀 Makefile Maestro - Docker Monorepo SIB-CR
# ==============================================

# ==============================================
# 🧱 VARIABLES
# ==============================================

COMPOSE_PROD := docker-compose.prod.yml
COMPOSE_DEV  := docker-compose.dev.yml
ENV_PROD     := .env.prod
ENV_DEV      := .env.dev
DOCKER_USER  := lpcodeadmin
TAG          := latest
TAG_DEV      := dev

# ==============================================
# 📦 SERVICIOS PROD 🚀 (Definidos en docker-compose.prod.yml)
# ==============================================

BACKEND_SERVICE := backend
ADMIN_SERVICE   := admin
PUBLIC_SERVICE  := publico
DB_SERVICE      := db

# ==============================================
# 📦 SERVICIOS DEV 🧪  (Definidos en docker-compose.dev.yml)
# ==============================================

BACKEND_DEV_SERVICE := backend-dev
ADMIN_DEV_SERVICE   := admin-dev
PUBLIC_DEV_SERVICE  := publico-dev
DB_DEV_SERVICE      := db-dev

# ==============================================
# 🐳 CONTENEDORES (Nombres fijos para comandos directos de Docker)
# ==============================================

BACKEND_CONTAINER := sib-cr-backend-prod
DB_CONTAINER      := sib-cr-database-prod
ADMIN_CONTAINER   := sib_cr_frontend_admin_prod
PUBLIC_CONTAINER  := sib_cr_frontend_publico_prod

BACKEND_DEV_CONTAINER := sib-cr-backend-dev
DB_DEV_CONTAINER      := sib-cr-database-dev
ADMIN_DEV_CONTAINER   := sib_cr_frontend_admin_dev
PUBLIC_DEV_CONTAINER  := sib_cr_frontend_publico_dev

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
# 🚀 DESPLIEGUE Y ACTUALIZACIÓN EN ENTORNO DE PRODUCCIÓN (prod)
# ==============================================

# Levanta todo el sistema en producción
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

# Actualizar el proxy de producción de manera atómica inyectando su entorno para evitar los WARN
update-proxy-prod:
	@echo "$(BLUE)🔄 Recreando Proxy de Producción con soporte de redes...$(RESET)"
	docker compose -f $(COMPOSE_PROD) --env-file $(ENV_PROD) up -d --no-deps proxy
	@echo "$(GREEN)✅ Proxy de producción actualizado sin caídas.$(RESET)"

# ==============================================
# 🧪 DESPLIEGUE EN ENTORNO DE PRUEBAS (dev)
# ==============================================

# Levanta todo el sistema en desarrollo en el VPS
dev:
	@echo "$(BLUE)🏗️ Iniciando despliegue en entorno de desarrollo...$(RESET)"
	@docker compose -f $(COMPOSE_DEV) --env-file $(ENV_DEV) up -d
	@echo "$(GREEN)✨ ¡Sistema de desarrollo levantado exitosamente!$(RESET)"
	@export $$(grep -v '^#' $(ENV_DEV) | xargs) && \
	echo "$(YELLOW)Admin: $$ADMIN_URL$(RESET)" && \
	echo "$(YELLOW)Público: $$PUBLIC_URL$(RESET)"

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
# 🔄 ACTUALIZAR SERVICIOS ATÓMICAS EN PROD 🚀 EN EL VPS (Sin caída de otros servicios)
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
# 🔄 ACTUALIZAR SERVICIOS ATÓMICAS EN DESARROLLO (dev) 🧪 EN EL VPS (Sin caída de otros servicios)
# ==============================================

# Actualizar y refrescar todos los servicios de DEV en el VPS
update-dev-all:
	@echo "$(BLUE)🚀 Jalando últimas imágenes de DEV desde Docker Hub...$(RESET)"
	@docker compose -f $(COMPOSE_DEV) pull
	@docker compose -f $(COMPOSE_DEV) up -d
	@echo "$(GREEN)✅ Imágenes de desarrollo actualizadas en el VPS.$(RESET)"

# Actualizar Backend de DEV en el VPS
update-dev-backend:
	@echo "$(BLUE)🚀 Actualizando Backend...$(RESET)"
	@docker compose -f $(COMPOSE_DEV) pull $(BACKEND_DEV_SERVICE)
	@docker compose -f $(COMPOSE_DEV) up -d --no-deps $(BACKEND_DEV_SERVICE)
	@echo "$(GREEN)✅ Backend DEV 🧪 actualizado$(RESET)"

# Actualizar Frontend Admin de DEV en el VPS
update-dev-admin:
	@echo "$(BLUE)🚀 Actualizando Frontend Admin...$(RESET)"
	@docker compose -f $(COMPOSE_DEV) pull $(ADMIN_DEV_SERVICE)
	@docker compose -f $(COMPOSE_DEV) up -d --no-deps $(ADMIN_DEV_SERVICE)
	@echo "$(GREEN)✅ Frontend Admin DEV 🧪 actualizado$(RESET)"

# Actualizar Frontend Público de DEV en el VPS
update-dev-public:
	@echo "$(BLUE)🚀 Actualizando Frontend Público...$(RESET)"
	@docker compose -f $(COMPOSE_DEV) pull $(PUBLIC_DEV_SERVICE)
	@docker compose -f $(COMPOSE_DEV) up -d --no-deps $(PUBLIC_DEV_SERVICE)
	@echo "$(GREEN)✅ Frontend Público DEV 🧪 actualizado$(RESET)"

# ==============================================
# 🛑 APAGADO Y LIMPIEZA EN ENTORNO DE PRODUCCIÓN (prod) 🚀 EN EL VPS
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
# 🛑 APAGADO Y LIMPIEZA EN ENTORNO DE DESARROLLO (dev) 🧪 EN EL VPS
# ==============================================

# Detiene el entorno de desarrollo en el VPS
down-dev:
	@echo "$(RED)🗑️ Deteniendo contenedores de desarrollo...$(RESET)"
	@docker compose -f $(COMPOSE_DEV) down

# ==============================================
# 📊 MONITOREO Y LOGS DE PRODUCCION (prod) 🚀 EN EL VPS
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
# 📊 MONITOREO Y LOGS DE DESARROLLO (dev) 🧪 EN EL VPS
# ==============================================

## Logs del Backend
logs-dev-backend: 
	@docker logs -f $(BACKEND_CONTAINER)

## Logs de la Base de Datos
logs-dev-db: 
	@docker logs -f $(DB_DEV_CONTAINER)

## Logs del Frontend Admin
logs-dev-admin: 
	@docker logs -f $(ADMIN_DEV_CONTAINER)

## Logs del Frontend Público
logs-dev-public: 
	@docker logs -f $(PUBLIC_DEV_CONTAINER)

## Logs de todos los servicios
logs-dev-all: 
	@docker compose -f $(COMPOSE_DEV) logs -f

# ==============================================
# 🐘 BASE DE DATOS PRODUCCION (PostgreSQL)
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
# 🐘 BASE DE DATOS DESARROLLO (PostgreSQL)
# ==============================================

# Terminal interactiva de la BD de DEV
db-dev-shell: 
	@docker exec -it $(DB_DEV_CONTAINER) psql -U $(DATASOURCE_USERNAME) -d $(DATASOURCE_DB_NAME)

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

# Obtiene la IP del Gateway de la red del proyecto en el VPS
docker-gateway:
	@echo "🔍 Obteniendo el Gateway de la red sib-cr-network en el VPS..."
	@ssh $(VPS_USER)@$(VPS_IP) "docker network inspect sib-cr-monorepo_sib-cr-network | grep Gateway"

# Obtiene la IP interna exacta de cualquier contenedor pasando el nombre
# Ejemplo de uso en terminal: make docker-ip NAME=sib-cr-database-prod
docker-ip:
	@if [ -z "$(NAME)" ]; then \
		echo "⚠️ Error: Debes especificar el nombre del contenedor. Ejemplo: make docker-ip NAME=sib-cr-database-prod"; \
	else \
		echo "📦 Buscando IP interna para el contenedor: $(NAME)..."; \
		ssh $(VPS_USER)@$(VPS_IP) "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(NAME)"; \
	fi

# ==============================================
# 🏭 CONSTRUCCIÓN LOCAL PARA PRODUCCIÓN (Solo construir para pruebas locales no las sube a Docker Hub) (CI/CD Local)
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
		--build-arg VITE_GOOGLE_MAPS_API_KEY=$(VITE_GOOGLE_MAPS_API_KEY) \
		-t $(DOCKER_USER)/sib-frontend-publico:$(TAG) ./Frontend-Public

# ==============================================
# 🏭 CONSTRUCCIÓN PARA DESARROLLO (CI/CD Local - DEV. no las sube a Docker Hub)
# ==============================================

# Construye todas las imágenes de desarrollo localmente
build-dev-local: build-dev-backend-local build-dev-admin-local build-dev-public-local
	@echo "$(GREEN)✅ Imágenes de desarrollo construidas localmente. Listas para probar o subir.$(RESET)"

# Build Backend - Desarrollo
build-dev-backend-local:
	@echo "$(BLUE)📦 Construyendo Backend para Desarrollo local...$(RESET)"
	docker build -t $(DOCKER_USER)/sib-backend:$(TAG_DEV) ./Backend

# Build Frontend Admin - Desarrollo (Inyecta la URL de la API de desarrollo)
build-dev-admin-local:
	@echo "$(BLUE)📦 Construyendo Frontend Admin para Desarrollo local...$(RESET)"
	@export $$(grep -v '^#' $(ENV_DEV) | xargs) && \
	docker build --target prod \
		--build-arg VITE_API_URL=$$URL_BASE_API_BACKEND \
		-t $(DOCKER_USER)/sib-frontend-admin:$(TAG_DEV) ./Frontend-Admin

# Build Frontend Público - Desarrollo (Inyecta API de desarrollo y la Key de Maps de Dev)
build-dev-public-local:
	@echo "$(BLUE)📦 Construyendo Frontend Público para Desarrollo local...$(RESET)"
	@export $$(grep -v '^#' $(ENV_DEV) | xargs) && \
	docker build --target prod \
		--build-arg VITE_API_URL=$$URL_BASE_API_BACKEND \
		--build-arg VITE_GOOGLE_MAPS_API_KEY=$$VITE_GOOGLE_MAPS_API_KEY \
		-t $(DOCKER_USER)/sib-frontend-publico:$(TAG_DEV) ./Frontend-Public


# ==============================================
# 🏭 FABRICA DE COMPILACIÓN A PRODUCCION - TAG: latest (Para constuir y enviar a docker hub)
# ==============================================

# Construir y subir todas las imágenes
build-and-push: build-backend build-admin build-public
	@echo "$(GREEN)🚀 ¡Todas las imágenes con Tag :latest han sido enviadas a Docker Hub!$(RESET)"

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
		--build-arg VITE_GOOGLE_MAPS_API_KEY=$(VITE_GOOGLE_MAPS_API_KEY) \
		-t $(DOCKER_USER)/sib-frontend-publico:$(TAG) ./Frontend-Public
	docker push $(DOCKER_USER)/sib-frontend-publico:$(TAG)

# ==============================================
# 🏭 FABRICA DE COMPILACIÓN A DESARROLLO - TAG: dev (Para constuir y enviar a docker hub)
# ==============================================

# Construir y subir todas las imágenes con Tag :dev
build-dev-and-push: build-dev-backend build-dev-admin build-dev-public
	@echo "$(GREEN)🚀 ¡Todas las imágenes con Tag :dev han sido enviadas a Docker Hub!$(RESET)"

# Construir y subir Backend con Tag :dev
build-dev-backend:
	@echo "$(BLUE)📦 Construyendo Backend para DEV...$(RESET)"
	docker build -t $(DOCKER_USER)/sib-backend:$(TAG_DEV) ./Backend
	docker push $(DOCKER_USER)/sib-backend:$(TAG_DEV)

# Construir y subir Frontend Admin con Tag :dev
build-dev-admin:
	@echo "$(BLUE)📦 Construyendo Frontend Admin para DEV...$(RESET)"
	@export $$(grep -v '^#' $(ENV_DEV) | xargs) && \
	docker build --target prod \
		--build-arg VITE_API_URL=$$URL_BASE_API_BACKEND \
		-t $(DOCKER_USER)/sib-frontend-admin:$(TAG_DEV) ./Frontend-Admin
	docker push $(DOCKER_USER)/sib-frontend-admin:$(TAG_DEV)

# Construir y subir Frontend Público con Tag :dev
build-dev-public:
	@echo "$(BLUE)📦 Construyendo Frontend Público para DEV...$(RESET)"
	@export $$(grep -v '^#' $(ENV_DEV) | xargs) && \
	docker build --target prod \
		--build-arg VITE_API_URL=$$URL_BASE_API_BACKEND \
		--build-arg VITE_GOOGLE_MAPS_API_KEY=$$VITE_GOOGLE_MAPS_API_KEY \
		-t $(DOCKER_USER)/sib-frontend-publico:$(TAG_DEV) ./Frontend-Public
	docker push $(DOCKER_USER)/sib-frontend-publico:$(TAG_DEV)


# ==============================================
# 🖥 SSH CONEXIÓN REMOTA (VPS)
# ==============================================

ssh-vps:
	@echo "🖥️ Conectando a la terminal del VPS..."
	ssh $(VPS_USER)@$(VPS_IP)

# ==============================================
# 🔗 SSH TUNNEL PARA ACCESO AL PROXY
# ==============================================

proxy-tunnel:
	@echo "🚀 Abriendo túnel seguro hacia el panel de administración..."
	@echo "🔗 Una vez abierto, accede en tu PC a: http://localhost:8080"
	@echo "⚠️ No cierres esta terminal mientras uses el panel."
	ssh -L 8080:localhost:81 $(VPS_USER)@$(VPS_IP)

# ==============================================
# 🔗 SSH TUNNELS INDIVIDUALES PARA PRODUCCIÓN (prod) (Base de Datos)
# ==============================================

# Abre exclusivamente el túnel para la Base de Datos (PostgreSQL)
# Cambiar la IP interna (172.18.0.5) si llega a cambiar en el futuro
db-tunnel:
	@echo "🗄️ Abriendo túnel seguro hacia PostgreSQL en el VPS..."
	@echo "🔗 Configura tu pgAdmin4 local con -> Host: host.docker.internal | Port: 5433"
	@echo "⚠️ No cierres esta terminal mientras uses la base de datos."
	ssh -L 5433:172.18.0.5:5432 $(VPS_USER)@$(VPS_IP)

# ==============================================
# 🔗 SSH TUNNELS INDIVIDUALES PARA DESARROLLO (dev) Base de Datos)
# ==============================================

# Túnel SSH para la Base de Datos de QA (Mapeado al puerto local 5434 de tu Mac)
db-dev-tunnel:
	@echo "$(BLUE)🗄️ Abriendo túnel seguro hacia la DB de QA...$(RESET)"
	@echo "🔗 Configura tu pgAdmin4 local con -> Host: host.docker.internal | Port: 5434"
	ssh -L 5434:$(BACKEND_DEV_CONTAINER):5432 $(VPS_USER)@$(VPS_IP)

# ==============================================
# 📘 HELP
# ==============================================

help:
	@echo ""
	@echo "$(GREEN)==================================================================$(RESET)"
	@echo "$(GREEN)🚀 MAKEFILE MAESTRO INTERNIVEL - SIB-CR (PROD 🚀 & DEV 🧪)$(RESET)"
	@echo "$(GREEN)==================================================================$(RESET)"
	@echo ""

	@echo "$(YELLOW)🚀 DESPLIEGUE Y ACTUALIZACIÓN (PRODUCCIÓN)$(RESET)"
	@echo "  make prod                 → Levantar entorno productivo completo"
	@echo "  make prod-build           → Rebuild completo y despliegue de producción"
	@echo "  make update-proxy-prod    → Recrear Proxy de Prod con soporte de redes (Sin caídas)"
	@echo "  make update-all           → Descargar imágenes y actualizar todo producción"
	@echo "  make update-backend       → Actualizar Backend en Producción (Atómico)"
	@echo "  make update-admin         → Actualizar Frontend Admin en Producción (Atómico)"
	@echo "  make update-public        → Actualizar Frontend Público en Producción (Atómico)"
	@echo ""

	@echo "$(YELLOW)🧪 DESPLIEGUE Y ACTUALIZACIÓN (DESARROLLO)$(RESET)"
	@echo "  make dev                  → Levantar entorno de desarrollo completo en el VPS"
	@echo "  make update-dev-all       → Descargar imágenes y actualizar todo desarrollo"
	@echo "  make update-dev-backend   → Actualizar Backend en Desarrollo (Atómico)"
	@echo "  make update-dev-admin     → Actualizar Frontend Admin en Desarrollo (Atómico)"
	@echo "  make update-dev-public    → Actualizar Frontend Público en Desarrollo (Atómico)"
	@echo ""

	@echo "$(YELLOW)🔄 REINICIO DE SERVICIOS (PRODUCCIÓN)$(RESET)"
	@echo "  make restart              → Reiniciar todos los servicios de producción"
	@echo "  make restart-backend      → Reiniciar Backend producción"
	@echo "  make restart-db           → Reiniciar PostgreSQL producción"
	@echo "  make restart-admin        → Reiniciar Frontend Admin producción"
	@echo "  make restart-public       → Reiniciar Frontend Público producción"
	@echo ""

	@echo "$(YELLOW)📊 MONITOREO, INSPECCIÓN Y LOGS (PRODUCCIÓN 🚀)$(RESET)"
	@echo "  make status               → Estado actual de los contenedores de producción"
	@echo "  make stats                → Consumo de CPU, RAM y Red en tiempo real del VPS"
	@echo "  make logs-all             → Logs agregados de todo el entorno de producción"
	@echo "  make logs-backend         → Logs en vivo del Backend de producción"
	@echo "  make logs-db              → Logs en vivo de la Base de Datos de producción"
	@echo "  make logs-admin           → Logs en vivo del Frontend Admin de producción"
	@echo "  make logs-public          → Logs en vivo del Frontend Público de producción"
	@echo "  make inspect-backend      → Inspección profunda de configuración del Backend"
	@echo "  make inspect-db           → Inspección profunda de configuración de la Base de Datos"
	@echo "  make inspect-admin        → Inspeccionar contenedor Admin"
	@echo "  make inspect-public       → Inspeccionar contenedor Público"
	@echo "  make config               → Validar y mostrar render final del compose de producción"
	@echo "  make validate             → Verificar sintaxis del docker-compose de producción"
	@echo ""

	@echo "$(YELLOW)📊 LOGS Y MONITOREO (DESARROLLO 🧪)$(RESET)"
	@echo "  make logs-dev-all         → Logs agregados de todo el entorno de desarrollo"
	@echo "  make logs-dev-backend     → Logs en vivo del Backend de desarrollo"
	@echo "  make logs-dev-db          → Logs en vivo de la Base de Datos de desarrollo"
	@echo "  make logs-dev-admin       → Logs en vivo del Frontend Admin de desarrollo"
	@echo "  make logs-dev-public      → Logs en vivo del Frontend Público de desarrollo"
	@echo ""

	@echo "$(YELLOW)🐘 BASE DE DATOS (MANTENIMIENTO E IMPORTACIÓN)$(RESET)"
	@echo "  make db-shell             → Terminal interactiva (psql) de la BD de Producción"
	@echo "  make db-dev-shell         → Terminal interactiva (psql) de la BD de Desarrollo"
	@echo "  make db-dump1             → Backup rápido de Producción a archivo .sql timestamps"
	@echo "  make db-dump2             → Backup alternativo abreviado de Producción"
	@echo "  make volume-ls            → Listar todos los volúmenes de Docker en el host"
	@echo "  make volume-inspect       → Ver la ruta y metadatos del volumen de producción"
	@echo "  make import-obras         → Importar y normalizar catálogo CSV a Producción"
	@echo "  make clean-temp           → Eliminar archivos residuales CSV del contenedor de producción"
	@echo ""

	@echo "$(YELLOW)🌐 REDES Y DIAGNÓSTICO DE COMPONENTES$(RESET)"
	@echo "  make networks-ls          → Listar las redes virtuales del motor de Docker"
	@echo "  make network-inspect      → Inspeccionar miembros e IPs de una red específica"
	@echo "  make ping-db              → Diagnóstico: Conectividad interna Backend -> Postgres"
	@echo "  make ping-backend         → Diagnóstico: Conectividad interna Admin -> Backend"
	@echo "  make ping-public          → Diagnóstico: Conectividad interna Público -> Backend"
	@echo "  make docker-gateway       → Obtener la IP de la puerta de enlace de red del VPS"
	@echo "  make docker-ip            → Obtener IP interna pasándole el nombre (Ej: make docker-ip NAME=...)"
	@echo ""

	@echo "$(YELLOW)🧹 LIMPIEZA Y SOPORTE PERIMETRAL (VPS)$(RESET)"
	@echo "  make down-all             → Detener y remover entorno de producción"
	@echo "  make down-dev             → Detener y remover entorno de desarrollo"
	@echo "  make down-volumes         → Detener producción y BORRAR VOLÚMENES FÍSICOS (Peligro)"
	@echo "  make clean-images         → Remover imágenes Docker huérfanas / sin uso"
	@echo "  make prune                → Limpieza global del sistema de Docker (Segura)"
	@echo "  make network-prune        → Eliminar redes virtuales en desuso"
	@echo "  make clean-danger         → HARD RESET: Borra todo el sistema, cachés y volúmenes (Cuidado)"
	@echo ""

	@echo "$(YELLOW)🏭 LA FÁBRICA EN LA NUBE - BUILDS + PUSH A DOCKER HUB (PRODUCCIÓN 🚀)$(RESET)"
	@echo "  make build-and-push     → Compilar y subir imágenes de PRODUCCIÓN (:latest)"
	@echo "  make build-backend      → Compilar Backend"
	@echo "  make build-admin        → Compilar Frontend Admin"
	@echo "  make build-public       → Compilar Frontend Público"
	@echo ""

	@echo "$(YELLOW)🏭 LA FÁBRICA EN LA NUBE - BUILDS + PUSH A DOCKER HUB (DESARROLLO 🧪)$(RESET)"
	@echo "  make build-dev-and-push  → Compilar y subir imágenes de DESARROLLO (:dev)"
	@echo "  make build-dev-backend   → Compilar Backend de desarrollo"
	@echo "  make build-dev-admin     → Compilar Frontend Admin de desarrollo"
	@echo "  make build-dev-public    → Compilar Frontend Público de desarrollo"
	@echo ""

	@echo "$(YELLOW)🏭 BUILD Y LOCAL (PRODUCCIÓN 🚀)$(RESET)"
	@echo "  make build-local              → Compilar todas las imágenes para Prod localmente ("Backend + Frontend Admin + Frontend Público Localmente")
	@echo "  make build-backend-local      → Compilar Backend Localmente"
	@echo "  make build-admin-local        → Compilar Frontend Admin Localmente"
	@echo "  make build-public-local       → Compilar Frontend Público Localmente"
	@echo ""

	@echo "$(YELLOW)🏭 BUILD Y LOCAL (DESARROLLO 🧪)$(RESET)"
	@echo "  make build-dev-local          → Compilar todas las imágenes para Dev localmente con .env.dev" ("Backend + Frontend Admin + Frontend Público Localmente con variables de desarrollo")
	@echo "  make build-dev-backend-local  → Compilar Backend Localmente con variables de desarrollo"
	@echo "  make build-dev-admin-local    → Compilar Frontend Admin Localmente con variables de desarrollo"
	@echo "  make build-dev-public-local   → Compilar Frontend Público Localmente con variables de desarrollo"
	@echo ""

	@echo "$(YELLOW)🌐 CONEXIONES REMOTAS Y TÚNELES SEGUROS (SSH)$(RESET)"
	@echo "  make ssh-vps              → Iniciar consola interactiva remota en el VPS"
	@echo "  make proxy-tunnel         → Túnel SSH para Nginx Proxy Manager Panel (Acceso: http://localhost:8080)"
	@echo "  make db-tunnel            → Túnel SSH para la base de datos de PRODUCCIÓN (Mapea a localhost:5433)"
	@echo "  make db-dev-tunnel        → Túnel SSH para la base de datos de DESARROLLO (Mapea a localhost:5434)"
	@echo "------------------------------------------------------------------"