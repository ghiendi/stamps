# Stamps.Gallery

## Tech Stack
- **Database**: MariaDB v12  
- **Backend/Frontend Runtime**: Node.js v22  
- **Frontend Framework**: React.js v19 (Next.js, Pages Router)  

## Project Structure
The project is built with **Next.js**.  
All source code is under the `src/` folder.

```
root/
├── src/
│   ├── lib/             # Shared libraries
│   │   ├── utils/       # Helper functions
│   │   ├── constants/   # Shared constants (UPPER_CASE)
│   │   └── middlewares/ # Shared middleware logic
│   │
│   ├── pages/           # Next.js Pages Router
│   │   ├── index.tsx    # Home page
│   │   └── api/         # API routes
│   │       └── hello.ts # Example API endpoint
│   │
│   └── components/      # React components (PascalCase)
│
├── .env.development     # Environment variables for development
├── package.json
└── README.md
```

### Folder Naming
- All folders use **snake_case**, except `components/` where React components use **PascalCase**.  
- Shared code is placed inside `/src/lib` to avoid duplication.  

## Coding Convention
To keep consistency across the whole project, we use the following naming rules:

- **File names**: snake_case  
  - Example: `user_profile.js`, `db_connection.ts`  

- **Functions**: snake_case  
  - Example: `get_user_data()`, `update_member_info()`  

- **Variables**: snake_case  
  - Example: `user_id`, `member_list`  

- **Constants**: UPPER_CASE  
  - Example: `MAX_RETRY`, `API_TIMEOUT`, `SESSION_PREFIX`  

- **Database**: snake_case for all objects  
  - Tables: `stamp_collection`, `user_account`  
  - Columns: `created_at`, `updated_at`  
  - Constraints / Index: `fk_user_id`, `idx_stamp_country`  

- **React Components**: PascalCase  
  - Example: `LoginForm`, `StampGallery`, `UserDashboard`  

## Environment Variables
The project uses environment-specific `.env` files.  
For local development, create a file named:

```
.env.development
```

### Example variables
```
# Database
DBR_HOST=localhost
DBR_PORT=3306
DBR_USER=root
DBR_PASS=password
DBR_NAME=stamps_gallery

```

- All variable names use **UPPER_CASE**.  
- Add `.env.production` for production environment.  
- Do not commit `.env.*` files to version control (add to `.gitignore`).  

## UI Guidelines

- **No shadows**: Do not use `box-shadow` or similar effects in the UI.  
- **Default font**: Maven Pro  
- **Default font size**: 14px  
- **Spacing**: padding và margin nhỏ, tối đa **8px**  
- **Responsive breakpoints**:
  - Mobile: ≤ 768px  
  - Tablet: 769px – 1024px  
  - Desktop: ≥ 1025px  
- **Max width (desktop layout)**: 1440px, content **center aligned**  
- Keep the interface flat, clean, and minimal.  
- Components should follow the project's naming conventions (PascalCase for React).  
