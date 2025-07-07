'use client'
import { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import FlowPayLogo from './FlowPayLogo'
import { Button } from './ui/button'
import { Home, Send, Users, History, Settings, Menu, X, LogOut, Bell } from 'lucide-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'

const navigationItems = [
  { id: 'dashboard', label: 'Dashboard', icon: Home, href: '/app/dashboard' },
  { id: 'make-payment', label: 'Make Payment', icon: Send, href: '/app/payments' },
  { id: 'vendors', label: 'Vendors', icon: Users, href: '/app/vendors' },
  { id: 'transactions', label: 'Transactions', icon: History, href: '/app/transactions' },
  { id: 'settings', label: 'Settings', icon: Settings, href: '/app/settings' },
]

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const { user, signOut } = useAuth()
  const pathname = usePathname()

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top Navigation */}
      <nav className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-40">
        <div className="px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="md:hidden p-2 rounded-lg hover:bg-gray-100"
              >
                {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
              </button>
              <FlowPayLogo size="small" />
            </div>
            
            <div className="flex items-center space-x-4">
              <button className="relative p-2 rounded-lg hover:bg-gray-100 transition-colors">
                <Bell className="w-6 h-6 text-gray-600" />
              </button>
              <div className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-semibold">
                  {user?.email?.[0]?.toUpperCase() || 'U'}
                </div>
                <Button
                  variant="ghost"
                  onClick={signOut}
                  className="hidden sm:flex items-center space-x-2"
                >
                  <LogOut className="w-5 h-5" />
                  <span>Logout</span>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </nav>

      <div className="flex h-[calc(100vh-64px)]">
        {/* Sidebar */}
        <aside className={`${mobileMenuOpen ? 'block' : 'hidden'} md:block w-64 bg-white border-r border-gray-200 overflow-y-auto`}>
          <nav className="p-4 space-y-1">
            {navigationItems.map((item) => (
              <Link
                key={item.id}
                href={item.href}
                onClick={() => setMobileMenuOpen(false)}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition-all ${
                  pathname === item.href
                    ? 'bg-gradient-to-r from-blue-50 to-purple-50 text-purple-700 font-medium'
                    : 'text-gray-600 hover:bg-gray-50'
                }`}
              >
                <item.icon className="w-5 h-5" />
                <span>{item.label}</span>
              </Link>
            ))}
          </nav>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-y-auto">
          <div className="p-6">
            {children}
          </div>
        </main>
      </div>
    </div>
  )
}