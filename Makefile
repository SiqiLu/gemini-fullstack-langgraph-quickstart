# ---------- 全局变量 ----------
COMPOSE_BASE = docker-compose.yml
COMPOSE_DEV  = docker-compose.dev.yml

# ---------- 统一声明 ----------
.PHONY: help deps-up deps-down dev-frontend dev-backend dev \
        dev-docker dev-docker-down logs clean

# ---------- 帮助 ----------
help:
	@echo "╔══════════════════════════════════════════════════════════════╗"
	@echo "║ Makefile - gemini-fullstack-langgraph commands               ║"
	@echo "╚══════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "本地热开发 (代码跑在宿主机):"
	@echo "  make deps-up           启动 Postgres / Redis 依赖容器"
	@echo "  make deps-down         停止上述依赖容器"
	@echo "  make dev-frontend      启动 Vite (http://localhost:5173)"
	@echo "  make dev-backend       启动 LangGraph dev (http://localhost:8000)"
	@echo "  make dev               并行启动前后端(需先 deps-up)"
	@echo ""
	@echo "容器化 dev 环境 (dist 已打包进镜像):"
	@echo "  make dev-docker        构建镜像并启动 langgraph-api (http://localhost:8123)"
	@echo "  make dev-docker-down   关闭并清理 dev 容器"
	@echo ""
	@echo "实用工具："
	@echo "  make logs              跟踪 langgraph-api 容器日志"
	@echo "  make clean             清理悬挂镜像/卷 (docker system prune)"
	@echo ""

# ---------- 依赖容器 ----------
deps-up:
	GEMINI_API_KEY="" LANGSMITH_API_KEY="" docker compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) up -d langgraph-redis langgraph-postgres

deps-down:
	GEMINI_API_KEY="" LANGSMITH_API_KEY="" docker compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) stop langgraph-redis langgraph-postgres

# ---------- 本地热开发 ----------
dev-frontend:
	@echo "Starting frontend development server..."
	cd frontend && npm run dev

dev-backend:
	@echo "Starting backend development server..."
	cd backend && bash -c "source venv/bin/activate && langgraph dev"

# 并行启动；Ctrl+C 可同时终止
dev: deps-up
	@echo "Starting both frontend and backend development servers..."
	$(MAKE) -j2 dev-frontend dev-backend

# ---------- 容器化 dev 发布 ----------
dev-docker:
	docker compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) up --build -d

dev-docker-down:
	docker compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) down

logs:
	docker compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) logs -f langgraph-api

# ---------- 清理 ----------
clean:
	docker compose -f $(COMPOSE_BASE) -f $(COMPOSE_DEV) down --volumes --remove-orphans
