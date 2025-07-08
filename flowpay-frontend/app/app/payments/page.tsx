'use client'
import { useState, useEffect } from 'react'
import { useSearchParams } from 'next/navigation'
import { apiClient, Vendor } from '@/lib/api'
import { getStripe } from '@/lib/stripe'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import PaymentForm from '@/components/forms/PaymentForm'
import toast from 'react-hot-toast'
import { CreditCard, Banknote, Zap, Check, AlertCircle, ArrowRight } from 'lucide-react'
import { formatCurrency } from '@/lib/utils'

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
      if (response.success && response.data && Array.isArray(response.data.vendors)) {
        const onboardedVendors = response.data.vendors.filter((v) => v && v.onboarded)
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


