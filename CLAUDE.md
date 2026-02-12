# AIBOD Standard Project

Full-stack web application with Django REST backend and Next.js frontend.
This file defines the shared conventions for all AIBOD projects.

# Tech Stack

- **Backend**: Python 3.12+ / Django 5.x / Django REST Framework
- **Frontend**: Next.js 14+ (App Router) / TypeScript / React 18+
- **Mock/Prototype**: Static HTML + vanilla JS, or minimal JSX files (in `mock/`)
- **Database**: PostgreSQL (default), SQLite for local dev
- **Infrastructure**: Docker / docker-compose

# Project Structure

```
├── backend/                # Django project root
│   ├── config/             # Django settings, urls, wsgi/asgi
│   ├── apps/               # Django apps (one directory per domain)
│   ├── tests/              # Backend tests (mirrors apps/ structure)
│   └── manage.py
├── frontend/               # Next.js project root
│   ├── src/
│   │   ├── app/            # App Router pages and layouts
│   │   ├── components/     # Reusable React components
│   │   ├── lib/            # Utilities, API client, helpers
│   │   ├── hooks/          # Custom React hooks
│   │   ├── types/          # TypeScript type definitions
│   │   └── i18n/           # Internationalization resources
│   ├── public/             # Static assets
│   └── __tests__/          # Frontend tests
├── mock/                   # HTML/JSX prototypes and mockups
├── docker/                 # Dockerfiles and docker-compose
├── docs/                   # Project documentation
└── CLAUDE.md
```

# Commands

## Backend
- Install deps: `cd backend && pip install -r requirements.txt`
- Run dev server: `cd backend && python manage.py runserver`
- Run all tests: `cd backend && pytest tests/ -x --tb=short`
- Run single test: `cd backend && pytest tests/path/to/test_file.py -x --tb=short`
- Lint & format: `cd backend && ruff check . && ruff format .`
- Migrations: `cd backend && python manage.py makemigrations && python manage.py migrate`
- Type check: `cd backend && mypy .`

## Frontend
- Install deps: `cd frontend && npm install`
- Run dev server: `cd frontend && npm run dev`
- Run all tests: `cd frontend && npm test`
- Run single test: `cd frontend && npm test -- path/to/file.test.tsx`
- Lint: `cd frontend && npm run lint`
- Format: `cd frontend && npx prettier --write .`
- Type check: `cd frontend && npx tsc --noEmit`
- Build: `cd frontend && npm run build`

## Docker
- Start all services: `docker compose up -d`
- Rebuild: `docker compose up -d --build`
- Stop: `docker compose down`
- Logs: `docker compose logs -f <service>`

# Code Style

## Python (Backend)
- Follow PEP 8 — enforced by Ruff
- Use type hints for all function signatures
- Django models: one model per file when complex, grouped by domain in apps
- API views: use DRF ViewSets and Serializers; avoid raw Django views for API
- Use `gettext_lazy` (`_()`) for all user-facing strings (i18n ready)
- Comments in Japanese by default; docstrings in English

## TypeScript (Frontend)
- Strict TypeScript — enforced by tsconfig `strict: true`
- Functional components only; use hooks for state and effects
- Use named exports; avoid default exports
- Use `next-intl` or equivalent for i18n; wrap all user-facing strings
- Comments in Japanese by default; JSDoc in English
- CSS: Tailwind CSS preferred; CSS Modules as fallback

## Mock / Prototype Files
- Place in `mock/` directory at project root
- Static HTML files: self-contained with inline styles or linked CSS
- JSX mockups: minimal dependencies, no build step required if possible
- Clearly mark as prototype: include `<!-- MOCK -->` or `// MOCK` header comment

# i18n Guidelines
- Default locale: `ja` (Japanese)
- Supported locales: `ja`, `en` (extend as needed)
- Backend: Django's built-in i18n with `gettext` / `.po` files
- Frontend: `next-intl` (or equivalent); translation files in `src/i18n/`
- All user-facing strings must be wrapped in translation functions
- Never hardcode user-visible text directly in templates or components

# Testing

## Backend
- Framework: pytest + pytest-django
- Naming: `test_<module>.py` in `tests/` mirroring `apps/` structure
- Use factory_boy for test data; avoid fixtures where possible
- API tests: use DRF's `APIClient`
- Aim for test coverage on all public API endpoints

## Frontend
- Framework: Jest + React Testing Library
- Naming: `<Component>.test.tsx` in `__tests__/`
- Test user behavior, not implementation details
- Use MSW (Mock Service Worker) for API mocking

# Git Conventions
- Branch naming: `feature/<ticket>-<short-description>`, `fix/<ticket>-<short-description>`
- Commit messages: Conventional Commits format
  - `feat:` new feature
  - `fix:` bug fix
  - `docs:` documentation only
  - `refactor:` code refactoring (no functional change)
  - `test:` adding or updating tests
  - `chore:` maintenance tasks (deps, CI, config)
- Write commit messages in English
- Keep commits atomic — one logical change per commit

# Workflow
1. Understand the requirement before writing code
2. Check existing code for patterns to follow
3. Write or update tests alongside implementation
4. Run linter and type checker before committing
5. Run relevant tests to verify changes

# Guardrails
- Don't use `git push --force`; use `git push --force-with-lease` instead
- Don't modify migration files manually; regenerate with `makemigrations`
- Don't commit `.env` files; use `.env.example` as template
- Don't install packages globally; use virtual environments (backend) and local node_modules (frontend)
- Don't bypass linters with `# noqa` or `eslint-disable` without documenting the reason
- Don't use `any` type in TypeScript; define proper types or use `unknown`
