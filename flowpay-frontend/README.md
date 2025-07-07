# FlowPay Frontend

A modern, responsive React application built with Next.js 14, TypeScript, and Tailwind CSS.

## Features

- 🔐 Supabase Authentication
- 💳 Stripe Payment Integration  
- 🎨 Modern UI with Tailwind CSS
- 📱 Fully Responsive Design
- ⚡ Next.js 14 with App Router
- 🔒 TypeScript for Type Safety

## Quick Start

1. Install dependencies:
   npm install

2. Set up environment variables:
   cp .env.example .env.local
   # Edit .env.local with your actual values

3. Run development server:
   npm run dev

4. Open http://localhost:3000

## Environment Variables

Required variables in `.env.local`:

- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anon key  
- `NEXT_PUBLIC_API_URL` - Your backend API URL
- `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` - Your Stripe publishable key

## Deployment

This app is configured for deployment on Vercel with automatic deployments from GitHub.

## Tech Stack

- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Authentication**: Supabase Auth
- **Payments**: Stripe
- **Deployment**: Vercel