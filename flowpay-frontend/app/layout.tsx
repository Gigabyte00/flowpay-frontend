import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { AuthProvider } from '@/contexts/AuthContext'
import { Toaster } from 'react-hot-toast'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'FlowPay - Pay Anyone with Your Credit Card',
  description: 'Transform your credit card payments into ACH transfers, wires, or checks. Pay rent, tuition, medical bills, and more while earning rewards.',
  keywords: ['payments', 'credit card', 'ACH', 'wire transfer', 'rent payment', 'stripe'],
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <AuthProvider>
          {children}
          <Toaster />
        </AuthProvider>
      </body>
    </html>
  )
}