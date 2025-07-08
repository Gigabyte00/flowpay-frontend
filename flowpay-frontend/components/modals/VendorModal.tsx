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
      if (response.success && response.data) {
        // Defensive: check for vendor and onboardingUrl
        const vendor = (response.data as any).vendor
        const onboardingUrl = (response.data as any).onboardingUrl
        if (vendor) {
          onVendorCreated(vendor)
        }
        // Open onboarding URL if provided
        if (onboardingUrl) {
          const shouldOpen = window.confirm(
            'Vendor created! The vendor needs to complete Stripe onboarding. Open onboarding page now?'
          )
          if (shouldOpen) {
            window.open(onboardingUrl, '_blank')
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
