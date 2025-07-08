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
