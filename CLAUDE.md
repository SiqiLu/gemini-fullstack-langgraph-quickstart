# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Quick Start
```bash
# Start development environment (requires GEMINI_API_KEY in backend/.env)
make dev                    # Starts both frontend and backend with dependencies
make deps-up               # Start only Postgres/Redis dependencies
make deps-down             # Stop dependencies
```

### Backend Commands
```bash
cd backend
pip install .              # Install backend dependencies
langgraph dev              # Start LangGraph development server (http://localhost:2024)
make test                  # Run unit tests
make lint                  # Run linters (ruff, mypy)
make format                # Format code with ruff
```

### Frontend Commands
```bash
cd frontend
npm install                # Install frontend dependencies
npm run dev                # Start Vite development server (http://localhost:5173)
npm run build              # Build for production
npm run lint               # Run ESLint
```

### Docker Commands
```bash
# Build and run production container
docker build -t gemini-fullstack-langgraph -f Dockerfile .
GEMINI_API_KEY=<key> LANGSMITH_API_KEY=<key> docker-compose up

# Development container
make dev-docker            # Build and run with dependencies (http://localhost:8123)
make dev-docker-down       # Stop containers
```

## Architecture Overview

### Backend (LangGraph Agent)
- **Core Agent**: `backend/src/agent/graph.py` - Main LangGraph research agent with iterative web search
- **State Management**: `backend/src/agent/state.py` - TypedDict states for graph nodes
- **Configuration**: `backend/src/agent/configuration.py` - Agent configuration schema
- **Entry Point**: `backend/src/agent/app.py` - FastAPI application serving the agent

### Agent Flow
1. **Query Generation**: Generates multiple search queries from user input
2. **Web Research**: Parallel web searches using Google Search API with Gemini
3. **Reflection**: Analyzes results to identify knowledge gaps
4. **Iterative Refinement**: Generates follow-up queries if needed (configurable loops)
5. **Answer Finalization**: Synthesizes final answer with citations

### Frontend (React/Vite)
- **Main App**: `frontend/src/App.tsx` - Root component with LangGraph streaming integration
- **Components**: `frontend/src/components/` - UI components using Shadcn/UI
- **Streaming**: Uses `@langchain/langgraph-sdk/react` for real-time agent updates
- **Styling**: Tailwind CSS with custom dark theme

### Key Dependencies
- **Backend**: LangGraph, LangChain, Google Gemini API, FastAPI, Python 3.11+
- **Frontend**: React 19, Vite, Tailwind CSS, Shadcn/UI, TypeScript
- **Infrastructure**: Redis (pub-sub), Postgres (state persistence)

## Environment Setup

Required environment variables in `backend/.env`:
- `GEMINI_API_KEY`: Google Gemini API key (required)
- `LANGSMITH_API_KEY`: LangSmith API key (optional, for production)

## API Configuration

The frontend connects to different backend URLs based on environment:
- Development: `http://localhost:2024` (LangGraph dev server)
- Production: `http://localhost:8123` (Docker container)

## Testing

- Backend tests: `make test` (pytest)
- Frontend linting: `npm run lint` (ESLint)
- Backend linting: `make lint` (ruff, mypy)

## CLI Usage

Test the agent directly:
```bash
cd backend
python examples/cli_research.py "Your research question"
```