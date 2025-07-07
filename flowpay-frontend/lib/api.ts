import { supabase } from './supabase'

const API_URL = process.env.NEXT_PUBLIC_API_URL

interface ApiResponse<T = any> {
  success: boolean
  data?: T
  error?: string
  errors?: any[]
}

class ApiClient {
  private async getAuthToken(): Promise<string | null> {
    const { data: { session } } = await supabase.auth.getSession()
    return session?.access_token || null
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const token = await this.getAuthToken()
    
    const config: RequestInit = {
      headers: {
        'Content-Type': 'application/json',
        ...(token && { Authorization: `Bearer ${token}` }),
        ...options.headers,
      },
      ...options,
    }

    try {
      const response = await fetch(`${API_URL}${endpoint}`, config)
      const data = await response.json()

      if (!response.ok) {
        return { success: false, error: data.error || 'Request failed', errors: data.errors }
      }

      return { success: true, data }
    } catch (error) {
      console.error('API Error:', error)
      return { success: false, error: 'Network error' }
    }
  }

  // User methods
  async getUserProfile() {
    return this.request('/users/profile')
  }

  async getDashboardStats() {
    return this.request('/users/dashboard-stats')
  }

  // Vendor methods
  async getVendors() {
    return this.request('/vendors')
  }

  async createVendor(data: any) {
    return this.request('/vendors', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async getVendorStatus(vendorId: string) {
    return this.request(`/vendors/${vendorId}/status`)
  }

  async getVendorDashboard(vendorId: string) {
    return this.request(`/vendors/${vendorId}/dashboard`, {
      method: 'POST',
    })
  }

  // Payment methods
  async createPaymentIntent(data: any) {
    return this.request('/payments/create-intent', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async completePayment(data: any) {
    return this.request('/payments/complete', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Transaction methods
  async getTransactions(params?: any) {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return this.request(`/transactions${queryString ? `?${queryString}` : ''}`)
  }
}

export const apiClient = new ApiClient()