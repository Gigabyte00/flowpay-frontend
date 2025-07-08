#!/bin/bash

# FlowPay Complete Pages Generation Script
# This script creates ALL missing pages and components

echo "🎨 Generating ALL FlowPay Frontend Pages and Components..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Please run this script from your flowpay-frontend directory"
    exit 1
fi

# Create missing directories
echo "📁 Creating missing directories..."
mkdir -p app/app/{vendors,payments,transactions,settings}
mkdir -p components/{forms,charts,modals}

# Create Vendors Page
echo "👥 Creating Vendors page..."
cat > app/app/vendors/page.tsx << 'EOF'
'use client'
import { useState, useEffect } from 'react'
import { apiClient } from '@/lib/api'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import VendorModal from '@/components/modals/VendorModal'
import toast from 'react-hot-toast'
import { Users, Plus, Search, ExternalLink, CheckCircle, Clock, AlertCircle } from 'lucide-react'

interface Vendor {
  id: string
  name: string
  email: string
  type: string
  stripe_account_id: string
  onboarded: boolean
  last_payment: string
  total_amount: number
  created_at: string
}

export default function VendorsPage() {
  const [vendors, setVendors] = useState<Vendor[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [showModal, setShowModal] = useState(false)

  useEffect(() => {
    fetchVendors()
  }, [])

  const fetchVendors = async () => {
    try {
      const response = await apiClient.getVendors()
      if (response.success) {
        setVendors(response.data.vendors || [])
      } else {
        toast.error('Failed to fetch vendors')
      }
    } catch (error) {
      toast.error('Error loading vendors')
    } finally {
      setLoading(false)
    }
  }

  const handleVendorCreated = (newVendor: Vendor) => {
    setVendors([newVendor, ...vendors])
    setShowModal(false)
    toast.success('Vendor created successfully!')
  }

  const handleOpenDashboard = async (vendor: Vendor) => {
    try {
      const response = await apiClient.getVendorDashboard(vendor.id)
      if (response.success) {
        window.open(response.data.url, '_blank')
      } else {
        toast.error('Failed to open dashboard')
      }
    } catch (error) {
      toast.error('Error opening dashboard')
    }
  }

  const filteredVendors = vendors.filter(vendor =>
    vendor.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    vendor.type.toLowerCase().includes(searchQuery.toLowerCase()) ||
    vendor.email.toLowerCase().includes(searchQuery.toLowerCase())
  )

  if (loading) {
    return <div className="p-6">Loading vendors...</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Vendors</h1>
          <p className="text-gray-600 mt-1">Manage your payment recipients</p>
        </div>
        <Button onClick={() => setShowModal(true)} className="flex items-center space-x-2">
          <Plus className="w-4 h-4" />
          <span>Add Vendor</span>
        </Button>
      </div>

      {/* Search */}
      <div className="bg-white rounded-xl shadow-sm p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
          <Input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search vendors..."
            className="pl-10"
          />
        </div>
      </div>

      {/* Vendors Grid */}
      {filteredVendors.length === 0 ? (
        <div className="bg-white rounded-xl shadow-sm p-12 text-center">
          <Users className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">
            {vendors.length === 0 ? 'No vendors yet' : 'No vendors found'}
          </h3>
          <p className="text-gray-600 mb-6">
            {vendors.length === 0 
              ? 'Add your first vendor to start sending payments'
              : 'Try adjusting your search terms'
            }
          </p>
          {vendors.length === 0 && (
            <Button onClick={() => setShowModal(true)}>
              Add Your First Vendor
            </Button>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredVendors.map((vendor) => (
            <div key={vendor.id} className="bg-white rounded-xl shadow-sm p-6 hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start mb-4">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-500 rounded-lg flex items-center justify-center text-white font-semibold">
                  {vendor.name[0]?.toUpperCase()}
                </div>
                <div className="flex items-center space-x-2">
                  {vendor.onboarded ? (
                    <span className="px-2 py-1 bg-green-100 text-green-700 text-xs rounded-full flex items-center">
                      <CheckCircle className="w-3 h-3 mr-1" />
                      Verified
                    </span>
                  ) : (
                    <span className="px-2 py-1 bg-yellow-100 text-yellow-700 text-xs rounded-full flex items-center">
                      <Clock className="w-3 h-3 mr-1" />
                      Pending
                    </span>
                  )}
                </div>
              </div>
              
              <h3 className="font-semibold text-lg mb-2 truncate">{vendor.name}</h3>
              <div className="space-y-2 text-sm text-gray-600">
                <p className="truncate">
                  <span className="font-medium">Type:</span> {vendor.type}
                </p>
                <p className="truncate">
                  <span className="font-medium">Email:</span> {vendor.email}
                </p>
                {vendor.total_amount > 0 && (
                  <p>
                    <span className="font-medium">Total Paid:</span> ${vendor.total_amount.toLocaleString()}
                  </p>
                )}
                {vendor.last_payment && (
                  <p>
                    <span className="font-medium">Last Payment:</span> {new Date(vendor.last_payment).toLocaleDateString()}
                  </p>
                )}
              </div>
              
              <div className="mt-4 flex space-x-2">
                {vendor.onboarded && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleOpenDashboard(vendor)}
                    className="flex-1 text-xs"
                  >
                    <ExternalLink className="w-3 h-3 mr-1" />
                    Dashboard
                  </Button>
                )}
                <Button
                  variant="outline"
                  size="sm"
                  className="flex-1 text-xs"
                  onClick={() => {
                    // Navigate to make payment with this vendor pre-selected
                    window.location.href = `/app/payments?vendor=${vendor.id}`
                  }}
                >
                  Pay Now
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Vendor Modal */}
      <VendorModal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        onVendorCreated={handleVendorCreated}
      />
    </div>
  )
}
EOF

# Create Payments Page
echo "💳 Creating Payments page..."
cat > app/app/payments/page.tsx << 'EOF'
'use client'
import { useState, useEffect } from 'react'
import { useSearchParams } from 'next/navigation'
import { apiClient } from '@/lib/api'
import { getStripe } from '@/lib/stripe'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import PaymentForm from '@/components/forms/PaymentForm'
import toast from 'react-hot-toast'
import { CreditCard, Banknote, Zap, Check, AlertCircle, ArrowRight } from 'lucide-react'
import { formatCurrency } from '@/lib/utils'

interface Vendor {
  id: string
  name: string
  email: string
  type: string
  onboarded: boolean
}

export default function PaymentsPage() {
  const [vendors, setVendors] = useState<Vendor[]>([])
  const [selectedVendor, setSelectedVendor] = useState('')
  const [amount, setAmount] = useState('')
  const [description, setDescription] = useState('')
  const [payoutSpeed, setPayoutSpeed] = useState('standard')
  const [loading, setLoading] = useState(false)
  const [clientSecret, setClientSecret] = useState('')
  const searchParams = useSearchParams()

  useEffect(() => {
    fetchVendors()
    // Pre-select vendor if passed in URL
    const vendorId = searchParams.get('vendor')
    if (vendorId) {
      setSelectedVendor(vendorId)
    }
  }, [searchParams])

  const fetchVendors = async () => {
    try {
      const response = await apiClient.getVendors()
      if (response.success) {
        const onboardedVendors = response.data.vendors.filter((v: Vendor) => v.onboarded)
        setVendors(onboardedVendors)
      }
    } catch (error) {
      toast.error('Error loading vendors')
    }
  }

  const calculateFee = () => {
    if (!amount || isNaN(parseFloat(amount))) return { fee: 0, total: 0 }
    const amountNum = parseFloat(amount)
    const fee = amountNum * 0.035 // 3.5% fee
    return {
      fee: fee,
      total: amountNum + fee
    }
  }

  const handleCreatePaymentIntent = async () => {
    if (!selectedVendor || !amount) {
      toast.error('Please select a vendor and enter an amount')
      return
    }

    const vendor = vendors.find(v => v.id === selectedVendor)
    if (!vendor) {
      toast.error('Vendor not found')
      return
    }

    setLoading(true)

    try {
      const response = await apiClient.createPaymentIntent({
        amount: parseFloat(amount),
        vendorId: selectedVendor,
        description: description || `Payment to ${vendor.name}`,
        payoutSpeed
      })

      if (response.success) {
        setClientSecret(response.data.clientSecret)
      } else {
        toast.error(response.error || 'Failed to create payment')
      }
    } catch (error) {
      toast.error('Error creating payment')
    } finally {
      setLoading(false)
    }
  }

  const fees = calculateFee()

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Make a Payment</h1>
        <p className="text-gray-600 mt-1">Send payments to vendors using your credit card</p>
      </div>

      {!clientSecret ? (
        // Payment Setup Form
        <div className="bg-white rounded-xl shadow-sm p-6 space-y-6">
          {/* Vendor Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select Vendor *
            </label>
            <select
              value={selectedVendor}
              onChange={(e) => setSelectedVendor(e.target.value)}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              required
            >
              <option value="">Choose a vendor...</option>
              {vendors.map((vendor) => (
                <option key={vendor.id} value={vendor.id}>
                  {vendor.name} - {vendor.type}
                </option>
              ))}
            </select>
            {vendors.length === 0 && (
              <p className="text-sm text-gray-500 mt-2">
                No verified vendors found. <a href="/app/vendors" className="text-purple-600 hover:underline">Add a vendor first</a>.
              </p>
            )}
          </div>

          {/* Amount */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Payment Amount *
            </label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-500">$</span>
              <Input
                type="number"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                className="pl-8"
                placeholder="0.00"
                step="0.01"
                min="1"
                required
              />
            </div>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Description (Optional)
            </label>
            <Input
              type="text"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="What is this payment for?"
            />
          </div>

          {/* Payout Speed */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Payout Speed
            </label>
            <div className="space-y-3">
              <label className={`flex items-center justify-between p-4 rounded-lg border-2 cursor-pointer transition-all ${
                payoutSpeed === 'standard' ? 'border-purple-500 bg-purple-50' : 'border-gray-200 hover:border-gray-300'
              }`}>
                <input
                  type="radio"
                  name="payoutSpeed"
                  value="standard"
                  checked={payoutSpeed === 'standard'}
                  onChange={(e) => setPayoutSpeed(e.target.value)}
                  className="sr-only"
                />
                <div className="flex items-center">
                  <Banknote className="w-6 h-6 text-gray-600 mr-3" />
                  <div>
                    <p className="font-medium">Standard ACH</p>
                    <p className="text-sm text-gray-600">2-3 business days • Free</p>
                  </div>
                </div>
                {payoutSpeed === 'standard' && <Check className="w-5 h-5 text-purple-600" />}
              </label>

              <label className={`flex items-center justify-between p-4 rounded-lg border-2 cursor-pointer transition-all ${
                payoutSpeed === 'instant' ? 'border-purple-500 bg-purple-50' : 'border-gray-200 hover:border-gray-300'
              }`}>
                <input
                  type="radio"
                  name="payoutSpeed"
                  value="instant"
                  checked={payoutSpeed === 'instant'}
                  onChange={(e) => setPayoutSpeed(e.target.value)}
                  className="sr-only"
                />
                <div className="flex items-center">
                  <Zap className="w-6 h-6 text-yellow-600 mr-3" />
                  <div>
                    <p className="font-medium">Instant Payout</p>
                    <p className="text-sm text-gray-600">Within 30 minutes • 1% fee</p>
                  </div>
                </div>
                {payoutSpeed === 'instant' && <Check className="w-5 h-5 text-purple-600" />}
              </label>
            </div>
          </div>

          {/* Fee Breakdown */}
          {amount && parseFloat(amount) > 0 && (
            <div className="bg-gray-50 rounded-lg p-4 space-y-3">
              <h3 className="font-medium text-gray-900">Payment Summary</h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Payment Amount:</span>
                  <span className="font-medium">{formatCurrency(parseFloat(amount))}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Platform Fee (3.5%):</span>
                  <span className="font-medium">{formatCurrency(fees.fee)}</span>
                </div>
                <div className="border-t pt-2 flex justify-between">
                  <span className="text-gray-900 font-medium">Total Charge:</span>
                  <span className="font-bold text-lg">{formatCurrency(fees.total)}</span>
                </div>
              </div>
            </div>
          )}

          {/* Action Button */}
          <Button
            onClick={handleCreatePaymentIntent}
            disabled={loading || !selectedVendor || !amount || parseFloat(amount) <= 0}
            className="w-full"
            size="lg"
          >
            {loading ? (
              <div className="flex items-center">
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                Creating Payment...
              </div>
            ) : (
              <>
                <CreditCard className="w-5 h-5 mr-2" />
                Proceed to Payment
              </>
            )}
          </Button>
        </div>
      ) : (
        // Stripe Payment Form
        <PaymentForm
          clientSecret={clientSecret}
          amount={parseFloat(amount)}
          vendorName={vendors.find(v => v.id === selectedVendor)?.name || ''}
          onSuccess={() => {
            toast.success('Payment completed successfully!')
            // Reset form
            setClientSecret('')
            setAmount('')
            setDescription('')
            setSelectedVendor('')
          }}
          onError={(error) => {
            toast.error(error)
            setClientSecret('') // Allow retry
          }}
        />
      )}
    </div>
  )
}
EOF

# Create Transactions Page
echo "📊 Creating Transactions page..."
cat > app/app/transactions/page.tsx << 'EOF'
'use client'
import { useState, useEffect } from 'react'
import { apiClient } from '@/lib/api'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { formatCurrency, formatDate } from '@/lib/utils'
import toast from 'react-hot-toast'
import { Search, Filter, Download, ExternalLink, CheckCircle, Clock, XCircle, AlertTriangle } from 'lucide-react'

interface Transaction {
  id: string
  date: string
  merchant: string
  amount: number
  fee: number
  status: 'Pending' | 'Processing' | 'Completed' | 'Failed' | 'Cancelled'
  method: string
  stripe_payment_id: string
  stripe_transfer_id?: string
  description?: string
  vendors?: {
    id: string
    name: string
    type: string
  }
}

export default function TransactionsPage() {
  const [transactions, setTransactions] = useState<Transaction[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)

  useEffect(() => {
    fetchTransactions()
  }, [currentPage, statusFilter])

  const fetchTransactions = async () => {
    try {
      const params: any = { 
        page: currentPage,
        limit: 20
      }
      if (statusFilter) params.status = statusFilter

      const response = await apiClient.getTransactions(params)
      if (response.success) {
        setTransactions(response.data.transactions || [])
        setTotalPages(response.data.pagination?.pages || 1)
      } else {
        toast.error('Failed to fetch transactions')
      }
    } catch (error) {
      toast.error('Error loading transactions')
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'Completed':
        return <CheckCircle className="w-4 h-4 text-green-600" />
      case 'Processing':
      case 'Pending':
        return <Clock className="w-4 h-4 text-yellow-600" />
      case 'Failed':
      case 'Cancelled':
        return <XCircle className="w-4 h-4 text-red-600" />
      default:
        return <AlertTriangle className="w-4 h-4 text-gray-600" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Completed':
        return 'bg-green-100 text-green-800'
      case 'Processing':
      case 'Pending':
        return 'bg-yellow-100 text-yellow-800'
      case 'Failed':
      case 'Cancelled':
        return 'bg-red-100 text-red-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredTransactions = transactions.filter(transaction =>
    transaction.merchant.toLowerCase().includes(searchQuery.toLowerCase()) ||
    transaction.description?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    transaction.stripe_payment_id.toLowerCase().includes(searchQuery.toLowerCase())
  )

  if (loading) {
    return <div className="p-6">Loading transactions...</div>
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Transaction History</h1>
          <p className="text-gray-600 mt-1">View and track all your payments</p>
        </div>
        <Button variant="outline" className="flex items-center space-x-2">
          <Download className="w-4 h-4" />
          <span>Export</span>
        </Button>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl shadow-sm p-4 space-y-4 sm:space-y-0 sm:flex sm:items-center sm:space-x-4">
        <div className="flex-1">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <Input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search transactions..."
              className="pl-10"
            />
          </div>
        </div>
        <div className="sm:w-48">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
          >
            <option value="">All Statuses</option>
            <option value="Completed">Completed</option>
            <option value="Processing">Processing</option>
            <option value="Pending">Pending</option>
            <option value="Failed">Failed</option>
          </select>
        </div>
      </div>

      {/* Transactions Table */}
      <div className="bg-white rounded-xl shadow-sm overflow-hidden">
        {filteredTransactions.length === 0 ? (
          <div className="p-12 text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Search className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              {transactions.length === 0 ? 'No transactions yet' : 'No transactions found'}
            </h3>
            <p className="text-gray-600">
              {transactions.length === 0 
                ? 'Your payment history will appear here once you make your first payment.'
                : 'Try adjusting your search terms or filters.'
              }
            </p>
          </div>
        ) : (
          <>
            {/* Desktop Table */}
            <div className="hidden md:block overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Date
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Merchant
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Fee
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Method
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredTransactions.map((transaction) => (
                    <tr key={transaction.id} className="hover:bg-gray-50 transition-colors">
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {formatDate(transaction.date)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <p className="text-sm font-medium text-gray-900">{transaction.merchant}</p>
                          {transaction.description && (
                            <p className="text-sm text-gray-500 truncate max-w-32">{transaction.description}</p>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {formatCurrency(transaction.amount)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                        {formatCurrency(transaction.fee)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {transaction.method}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(transaction.status)}`}>
                          {getStatusIcon(transaction.status)}
                          <span className="ml-1">{transaction.status}</span>
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <Button variant="ghost" size="sm">
                          <ExternalLink className="w-4 h-4" />
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Mobile Cards */}
            <div className="md:hidden divide-y divide-gray-200">
              {filteredTransactions.map((transaction) => (
                <div key={transaction.id} className="p-4">
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <p className="font-medium text-gray-900">{transaction.merchant}</p>
                      <p className="text-sm text-gray-500">{formatDate(transaction.date)}</p>
                    </div>
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(transaction.status)}`}>
                      {getStatusIcon(transaction.status)}
                      <span className="ml-1">{transaction.status}</span>
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <div>
                      <p className="text-lg font-bold text-gray-900">{formatCurrency(transaction.amount)}</p>
                      <p className="text-sm text-gray-500">Fee: {formatCurrency(transaction.fee)} • {transaction.method}</p>
                    </div>
                    <Button variant="ghost" size="sm">
                      <ExternalLink className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>

            {/* Pagination */}
            {totalPages > 1 && (
              <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
                <div className="text-sm text-gray-500">
                  Page {currentPage} of {totalPages}
                </div>
                <div className="flex space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage(currentPage - 1)}
                    disabled={currentPage <= 1}
                  >
                    Previous
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage(currentPage + 1)}
                    disabled={currentPage >= totalPages}
                  >
                    Next
                  </Button>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}
EOF

# Create Settings Page
echo "⚙️ Creating Settings page..."
cat > app/app/settings/page.tsx << 'EOF'
'use client'
import { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { apiClient } from '@/lib/api'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import toast from 'react-hot-toast'
import { User, Bell, CreditCard, Shield, LogOut, Save } from 'lucide-react'

export default function SettingsPage() {
  const { user, profile, signOut, refreshProfile } = useAuth()
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: profile?.name || '',
    email: user?.email || ''
  })

  const handleProfileUpdate = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.name.trim()) {
      toast.error('Name is required')
      return
    }

    setLoading(true)
    try {
      const response = await apiClient.updateUserProfile({
        name: formData.name.trim()
      })

      if (response.success) {
        toast.success('Profile updated successfully')
        await refreshProfile()
      } else {
        toast.error(response.error || 'Failed to update profile')
      }
    } catch (error) {
      toast.error('Error updating profile')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Account Settings</h1>
        <p className="text-gray-600 mt-1">Manage your account preferences and security</p>
      </div>

      {/* Profile Section */}
      <div className="bg-white rounded-xl shadow-sm">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center space-x-3">
            <User className="w-6 h-6 text-purple-600" />
            <h2 className="text-lg font-semibold">Profile Information</h2>
          </div>
        </div>
        <form onSubmit={handleProfileUpdate} className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Full Name
            </label>
            <Input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              placeholder="Enter your full name"
              required
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <Input
              type="email"
              value={formData.email}
              disabled
              className="bg-gray-50"
            />
            <p className="text-xs text-gray-500 mt-1">
              Email cannot be changed. Contact support if needed.
            </p>
          </div>

          <div className="pt-4">
            <Button
              type="submit"
              disabled={loading}
              className="flex items-center space-x-2"
            >
              {loading ? (
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              ) : (
                <Save className="w-4 h-4" />
              )}
              <span>{loading ? 'Saving...' : 'Save Changes'}</span>
            </Button>
          </div>
        </form>
      </div>

      {/* Account Security */}
      <div className="bg-white rounded-xl shadow-sm">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center space-x-3">
            <Shield className="w-6 h-6 text-purple-600" />
            <h2 className="text-lg font-semibold">Security</h2>
          </div>
        </div>
        <div className="p-6 space-y-4">
          <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
            <div>
              <h3 className="font-medium">Password</h3>
              <p className="text-sm text-gray-600">Change your account password</p>
            </div>
            <Button variant="outline">
              Change Password
            </Button>
          </div>
          
          <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
            <div>
              <h3 className="font-medium">Two-Factor Authentication</h3>
              <p className="text-sm text-gray-600">Add an extra layer of security</p>
            </div>
            <Button variant="outline">
              Enable 2FA
            </Button>
          </div>
        </div>
      </div>

      {/* Payment Methods */}
      <div className="bg-white rounded-xl shadow-sm">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center space-x-3">
            <CreditCard className="w-6 h-6 text-purple-600" />
            <h2 className="text-lg font-semibold">Payment Methods</h2>
          </div>
        </div>
        <div className="p-6">
          <div className="text-center py-8">
            <CreditCard className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No payment methods</h3>
            <p className="text-gray-600 mb-4">Add a credit card to start making payments</p>
            <Button>Add Payment Method</Button>
          </div>
        </div>
      </div>

      {/* Notifications */}
      <div className="bg-white rounded-xl shadow-sm">
        <div className="p-6 border-b border-gray-200">
          <div className="flex items-center space-x-3">
            <Bell className="w-6 h-6 text-purple-600" />
            <h2 className="text-lg font-semibold">Notifications</h2>
          </div>
        </div>
        <div className="p-6 space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-medium">Email Notifications</h3>
              <p className="text-sm text-gray-600">Receive payment confirmations and updates</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" className="sr-only peer" defaultChecked />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
            </label>
          </div>
          
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-medium">Payment Reminders</h3>
              <p className="text-sm text-gray-600">Get reminded about upcoming scheduled payments</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" className="sr-only peer" defaultChecked />
              <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-purple-600"></div>
            </label>
          </div>
        </div>
      </div>

      {/* Danger Zone */}
      <div className="bg-white rounded-xl shadow-sm border-red-200 border">
        <div className="p-6 border-b border-red-200">
          <h2 className="text-lg font-semibold text-red-900">Danger Zone</h2>
        </div>
        <div className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-medium text-red-900">Sign Out</h3>
              <p className="text-sm text-red-700">Sign out of your FlowPay account</p>
            </div>
            <Button
              variant="destructive"
              onClick={signOut}
              className="flex items-center space-x-2"
            >
              <LogOut className="w-4 h-4" />
              <span>Sign Out</span>
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

# Create Vendor Modal Component
echo "🔨 Creating Vendor Modal component..."
cat > components/modals/VendorModal.tsx << 'EOF'
'use client'
import { useState } from 'react'
import { apiClient } from '@/lib/api'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import toast from 'react-hot-toast'
import { X, Building2, AlertCircle } from 'lucide-react'

interface VendorModalProps {
  isOpen: boolean
  onClose: () => void
  onVendorCreated: (vendor: any) => void
}

export default function VendorModal({ isOpen, onClose, onVendorCreated }: VendorModalProps) {
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    type: 'Business',
    businessType: 'individual'
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!formData.name || !formData.email) {
      toast.error('Please fill in all required fields')
      return
    }

    setLoading(true)

    try {
      const response = await apiClient.createVendor(formData)
      
      if (response.success) {
        onVendorCreated(response.data.vendor)
        
        // Open onboarding URL if provided
        if (response.data.onboardingUrl) {
          const shouldOpen = window.confirm(
            'Vendor created! The vendor needs to complete Stripe onboarding. Open onboarding page now?'
          )
          if (shouldOpen) {
            window.open(response.data.onboardingUrl, '_blank')
          }
        }
        
        // Reset form
        setFormData({
          name: '',
          email: '',
          type: 'Business',
          businessType: 'individual'
        })
      } else {
        toast.error(response.error || 'Failed to create vendor')
      }
    } catch (error) {
      toast.error('Error creating vendor')
    } finally {
      setLoading(false)
    }
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-xl p-6 max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold">Add New Vendor</h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Business Name *
            </label>
            <Input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              placeholder="e.g., ABC Property Management"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Email Address *
            </label>
            <Input
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({...formData, email: e.target.value})}
              placeholder="vendor@example.com"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Vendor Type
            </label>
            <select
              value={formData.type}
              onChange={(e) => setFormData({...formData, type: e.target.value})}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              <option value="Rent">Rent</option>
              <option value="Tuition">Tuition</option>
              <option value="Medical">Medical</option>
              <option value="Business">Business</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Business Type
            </label>
            <div className="space-y-2">
              <label className="flex items-center">
                <input
                  type="radio"
                  name="businessType"
                  value="individual"
                  checked={formData.businessType === 'individual'}
                  onChange={(e) => setFormData({...formData, businessType: e.target.value})}
                  className="mr-2"
                />
                Individual (sole proprietor)
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  name="businessType"
                  value="company"
                  checked={formData.businessType === 'company'}
                  onChange={(e) => setFormData({...formData, businessType: e.target.value})}
                  className="mr-2"
                />
                Company (LLC, Corp, etc.)
              </label>
            </div>
          </div>

          <div className="bg-blue-50 rounded-lg p-3 text-sm text-blue-800">
            <div className="flex items-start">
              <AlertCircle className="w-4 h-4 mt-0.5 mr-2 flex-shrink-0" />
              <div>
                <p className="font-medium mb-1">What happens next?</p>
                <p>The vendor will be redirected to Stripe to complete their account setup. They'll need to provide:</p>
                <ul className="list-disc list-inside mt-2 space-y-1">
                  <li>Business information</li>
                  <li>Bank account details</li>
                  <li>Tax identification</li>
                </ul>
              </div>
            </div>
          </div>

          <div className="flex space-x-3 pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={loading}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              disabled={loading}
              className="flex-1"
            >
              {loading ? (
                <div className="flex items-center">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  Creating...
                </div>
              ) : (
                <>
                  <Building2 className="w-4 h-4 mr-2" />
                  Add Vendor
                </>
              )}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
EOF

# Create Payment Form Component
echo "💳 Creating Payment Form component..."
cat > components/forms/PaymentForm.tsx << 'EOF'
'use client'
import { useState, useEffect } from 'react'
import { useStripe, useElements, CardElement, Elements } from '@stripe/react-stripe-js'
import { getStripe } from '@/lib/stripe'
import { apiClient } from '@/lib/api'
import { Button } from '@/components/ui/button'
import { formatCurrency } from '@/lib/utils'
import toast from 'react-hot-toast'
import { Lock, CheckCircle, AlertCircle } from 'lucide-react'

interface PaymentFormProps {
  clientSecret: string
  amount: number
  vendorName: string
  onSuccess: () => void
  onError: (error: string) => void
}

function PaymentFormContent({ clientSecret, amount, vendorName, onSuccess, onError }: PaymentFormProps) {
  const stripe = useStripe()
  const elements = useElements()
  const [loading, setLoading] = useState(false)
  const [succeeded, setSucceeded] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!stripe || !elements) {
      return
    }

    setLoading(true)

    const { error, paymentIntent } = await stripe.confirmCardPayment(clientSecret, {
      payment_method: {
        card: elements.getElement(CardElement)!,
        billing_details: {
          name: 'FlowPay Customer',
        },
      }
    })

    if (error) {
      onError(error.message || 'Payment failed')
      setLoading(false)
    } else if (paymentIntent?.status === 'succeeded') {
      setSucceeded(true)
      setLoading(false)
      onSuccess()
    }
  }

  const cardElementOptions = {
    style: {
      base: {
        fontSize: '16px',
        color: '#424770',
        '::placeholder': {
          color: '#aab7c4',
        },
      },
    },
  }

  if (succeeded) {
    return (
      <div className="bg-white rounded-xl shadow-sm p-6 text-center">
        <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-gray-900 mb-2">Payment Successful!</h3>
        <p className="text-gray-600">
          Your payment of {formatCurrency(amount)} to {vendorName} has been processed.
        </p>
      </div>
    )
  }

  return (
    <div className="bg-white rounded-xl shadow-sm p-6 space-y-6">
      <div className="text-center">
        <h3 className="text-lg font-semibold text-gray-900 mb-2">Complete Payment</h3>
        <p className="text-gray-600">
          Pay {formatCurrency(amount)} to {vendorName}
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Card Information
          </label>
          <div className="p-3 border border-gray-300 rounded-lg">
            <CardElement options={cardElementOptions} />
          </div>
        </div>

        <div className="bg-blue-50 rounded-lg p-4 text-sm text-blue-800">
          <div className="flex items-start">
            <AlertCircle className="w-4 h-4 mt-0.5 mr-2 flex-shrink-0" />
            <div>
              <p className="font-medium mb-1">Test Mode</p>
              <p>Use test card: 4242 4242 4242 4242 with any future expiry and CVC.</p>
            </div>
          </div>
        </div>

        <Button
          type="submit"
          disabled={!stripe || loading}
          className="w-full"
          size="lg"
        >
          {loading ? (
            <div className="flex items-center">
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
              Processing Payment...
            </div>
          ) : (
            <>
              <Lock className="w-4 h-4 mr-2" />
              Pay {formatCurrency(amount)}
            </>
          )}
        </Button>
      </form>

      <div className="flex items-center justify-center text-sm text-gray-500">
        <Lock className="w-4 h-4 mr-2" />
        Secured by Stripe • PCI DSS Compliant
      </div>
    </div>
  )
}

export default function PaymentForm(props: PaymentFormProps) {
  const stripePromise = getStripe()

  return (
    <Elements stripe={stripePromise}>
      <PaymentFormContent {...props} />
    </Elements>
  )
}
EOF

echo ""
echo "✅ All FlowPay pages and components created successfully!"
echo ""
echo "📁 Generated files:"
echo "   ✅ app/app/vendors/page.tsx - Complete vendor management"
echo "   ✅ app/app/payments/page.tsx - Payment processing with Stripe"
echo "   ✅ app/app/transactions/page.tsx - Transaction history with filters"
echo "   ✅ app/app/settings/page.tsx - User profile and account settings"
echo "   ✅ components/modals/VendorModal.tsx - Add vendor modal"
echo "   ✅ components/forms/PaymentForm.tsx - Stripe payment form"
echo ""
echo "🎨 Features included:"
echo "   ✅ Full vendor management with Stripe Connect onboarding"
echo "   ✅ Complete payment processing workflow"
echo "   ✅ Transaction history with search and filters"
echo "   ✅ User settings and profile management"
echo "   ✅ Responsive design for all screen sizes"
echo "   ✅ Real-time API integration"
echo "   ✅ Error handling and loading states"
echo ""
echo "📦 Next steps:"
echo "   1. npm install @stripe/react-stripe-js (if not already installed)"
echo "   2. npm run dev"
echo "   3. Test all pages and functionality"
echo "   4. Deploy to Vercel"
echo ""
echo "🚀 Your FlowPay frontend is now complete with all pages!"
