'use client'
import { useState, useEffect } from 'react'
import { apiClient } from '@/lib/api'
import { formatCurrency } from '@/lib/utils'
import { DollarSign, TrendingUp, Award, Users } from 'lucide-react'

export default function DashboardPage() {
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await apiClient.getDashboardStats()
        if (response.success) {
          setStats(response.data.stats)
        }
      } catch (error) {
        console.error('Error fetching stats:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

  if (loading) {
    return <div className="p-6">Loading dashboard...</div>
  }

  const statCards = [
    { label: 'Total Payments', value: formatCurrency(stats?.totalPayments || 0), icon: DollarSign },
    { label: 'This Month', value: formatCurrency(stats?.monthlyPayments || 0), icon: TrendingUp },
    { label: 'Active Vendors', value: stats?.activeVendors || 0, icon: Users },
    { label: 'Completed', value: stats?.completedTransactions || 0, icon: Award },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-1">Welcome back! Here's your payment overview.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((stat, index) => (
          <div key={index} className="bg-white rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between mb-4">
              <div className="w-12 h-12 bg-gradient-to-br from-blue-100 to-purple-100 rounded-lg flex items-center justify-center">
                <stat.icon className="w-6 h-6 text-purple-600" />
              </div>
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              <p className="text-sm text-gray-600 mt-1">{stat.label}</p>
            </div>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-xl p-6 shadow-sm">
        <h2 className="text-lg font-semibold mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="p-4 border border-gray-200 rounded-lg hover:border-purple-300 transition-colors text-left">
            <h3 className="font-medium">Make Payment</h3>
            <p className="text-sm text-gray-600">Send money to vendors</p>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:border-purple-300 transition-colors text-left">
            <h3 className="font-medium">Add Vendor</h3>
            <p className="text-sm text-gray-600">Set up new recipient</p>
          </button>
          <button className="p-4 border border-gray-200 rounded-lg hover:border-purple-300 transition-colors text-left">
            <h3 className="font-medium">View Transactions</h3>
            <p className="text-sm text-gray-600">Payment history</p>
          </button>
        </div>
      </div>
    </div>
  )
}