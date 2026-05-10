# ==============================================
# 🚀 Makefile Maestro - Cimientos del Renacimiento (SIB)
# ==============================================

# 🧱 Variables
COMPOSE_PROD := docker-compose.prod.yml
ENV_PROD     := .env.prod
DOCKER_USER  := lpcodeadmin
TAG          := latest

# 🎨 Colores
GREEN   := \033[0;32m
YELLOW  := \033[1;33m
BLUE    := \033[1;34m
RED     := \033[1;31m
RESET   := \033[0m

.DEFAULT_GOAL := help

# Incluimos las variables del .env para que estén disponibles en los comandos
# Esto permite usar $(URL_BASE_API_BACKEND) directamente
ifneq ("$(wildcard $(ENV_PROD))","")
    include $(ENV_PROD)
    export $(shell sed 's/=.*//' $(ENV_PROD))
endif

# ==============================================
# 🔧 COMANDOS PRINCIPALES
# ==============================================

# 🚀 Despliegue Total en Producción
prod:
	@echo "$(BLUE)🏗️ Iniciando despliegue total de producción...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) --env-file $(ENV_PROD) up -d
	@echo "$(GREEN)✨ ¡Sistema levantado exitosamente!$(RESET)"
	@echo "$(YELLOW)Admin: http://localhost:3001$(RESET)"
	@echo "$(YELLOW)Público: http://localhost:3000$(RESET)"

# 🛑 Detener todo el sistema
down:
	@echo "$(RED)🗑️ Deteniendo y eliminando contenedores del sistema...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) down

# 🔄 Reiniciar el sistema
restart:
	@echo "$(BLUE)🔄 Reiniciando servicios...$(RESET)"
	@docker compose -f $(COMPOSE_PROD) restart

# 💾 Generar Backup de la Base de Datos: Antes de hacer cualquier limpieza profunda en el servidor, exporta la base de datos.
db-dump:
	@echo "$(BLUE)💾 Generando backup de la base de datos...$(RESET)"
	@export $$(grep -v '^#' $(ENV_PROD) | xargs) && \
	docker exec sib-cr-database-prod pg_dump -U $$DATASOURCE_USERNAME $$DATASOURCE_DB_NAME > backup_$$(date +%F).sql
	@echo "$(GREEN)✅ Backup creado: backup_$$(date +%F).sql$(RESET)"

# 🔍 Ver Logs del Backend (en tiempo real)
logs-backend:
	@docker logs -f sib-cr-backend-prod

# 🔍 Ver Logs de la Base de Datos
logs-db:
	@docker logs -f sib-cr-database-prod

# 🧹 Limpieza de Imágenes (Segura):  Esto borra imágenes viejas que ocupan espacio en el disco del VPS pero no toca los datos.
prune:
	@echo "$(BLUE)🧹 Limpiando imágenes y constructores no utilizados...$(RESET)"
	docker system prune -f

# 🧼 Limpieza Profunda (Contenedores, Imágenes y Volúmenes)
# ¡CUIDADO! Esto borrará la base de datos si no haces backup
clean-danger:
	@echo "$(RED)⚠️  ADVERTENCIA: Se eliminarán volúmenes y datos de la DB.$(RESET)"
	@read -p "Esta acción es irreversible. ¿Deseas continuar? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "$(BLUE)🗑️  Procediendo con la limpieza total...$(RESET)"; \
		docker compose -f $(COMPOSE_PROD) down -v --rmi all; \
		echo "$(GREEN)✅ Limpieza completada.$(RESET)"; \
	else \
		echo "$(YELLOW)❌ Operación cancelada.$(RESET)"; \
	fi
	
# 🧪 Verificar estado de los contenedores
status:
	@docker compose -f $(COMPOSE_PROD) ps

# ==============================================
# 🏭 COMANDOS DE FÁBRICA (Solo en MacBook)
# ==============================================

# Construir y subir todas las imágenes
build-and-push: build-backend build-admin build-public
	@echo "$(GREEN)🚀 ¡Todas las imágenes han sido enviadas a Docker Hub!$(RESET)"

build-backend:
	@echo "$(BLUE)📦 Construyendo Backend...$(RESET)"
	docker build -t $(DOCKER_USER)/sib-backend:$(TAG) ./Backend
	docker push $(DOCKER_USER)/sib-backend:$(TAG)

build-admin:
	@echo "$(BLUE)📦 Construyendo Frontend Admin...$(RESET)"
	docker build --target prod \
		--build-arg VITE_API_URL=$(URL_BASE_API_BACKEND) \
		-t $(DOCKER_USER)/sib-frontend-admin:$(TAG) ./Frontend-Admin
	docker push $(DOCKER_USER)/sib-frontend-admin:$(TAG)

build-public:
	@echo "$(BLUE)📦 Construyendo Frontend Público...$(RESET)"
	docker build --target prod -t $(DOCKER_USER)/sib-frontend-publico:$(TAG) ./Frontend-Public
	docker push $(DOCKER_USER)/sib-frontend-publico:$(TAG)

# ==============================================
# 📘 AYUDA
# ==============================================
help:
	@echo ""
	@echo "$(GREEN)📘 Comandos disponibles para el Monorepo SIB:$(RESET)"
	@echo ""
	@echo "$(YELLOW)make prod$(RESET)          - Construye y levanta TODO el sistema en producción"
	@echo "$(YELLOW)make down$(RESET)          - Detiene y elimina los contenedores"
	@echo "$(YELLOW)make restart$(RESET)       - Reinicia los servicios"
	@echo "$(YELLOW)make logs-backend$(RESET)  - Ver logs del backend"
	@echo "$(YELLOW)make status$(RESET)        - Ver estado de los contenedores"
	@echo "$(YELLOW)make clean-danger$(RESET)  - Borrado total (incluye base de datos)"
	@echo ""