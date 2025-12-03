# Intraforms Frontend

Vue.js frontend application with Vuetify for Intraforms 2.0.

## Project Structure

```
├── src/
│   ├── components/       # Reusable Vue components
│   ├── views/           # Page-level components
│   ├── router/          # Vue Router configuration
│   ├── stores/          # Pinia state management
│   ├── services/        # API services and utilities
│   ├── plugins/         # Vuetify and other plugins
│   ├── App.vue          # Root component
│   └── main.js          # Application entry point
├── public/              # Static assets
├── index.html           # HTML template
├── vite.config.js       # Vite configuration
└── package.json         # Dependencies and scripts
```

## Setup

### Install Dependencies

```bash
npm install
```

### Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:3000`

### Build for Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Technologies

- **Vue 3** - Progressive JavaScript framework
- **Vuetify 3** - Material Design component framework
- **Vue Router** - Official router for Vue.js
- **Pinia** - State management library
- **Vite** - Next generation frontend tooling
- **Axios** - HTTP client for API requests

## Configuration

Create a `.env` file based on `.env.example` to configure environment variables:

```bash
cp .env.example .env
```

## Features

- ✅ Vue 3 Composition API
- ✅ Vuetify 3 Material Design components
- ✅ Vue Router for navigation
- ✅ Pinia for state management
- ✅ Axios for API integration
- ✅ Vite for fast development
- ✅ ESLint for code quality
