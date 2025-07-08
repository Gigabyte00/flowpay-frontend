import { supabase } from './supabase'

// --- Define types for your API responses ---
export interface UserProfile {
  user: any // Replace 'any' with your actual user type if available
}
export interface DashboardStats {
  stats: {
    totalPayments: number
    monthlyPayments: number
    activeVendors: number
    completedTransactions: number
    // Add more fields as needed
  }
}
export interface Vendor {
  id: string
  name: string
  email: string
  type: string
  onboarded: boolean
  stripe_account_id: string
  last_payment: string
  total_amount: number
  created_at: string
}
export interface Transaction {
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

interface ApiResponse<T> {
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
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}${endpoint}`, config)
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
  async getUserProfile(): Promise<ApiResponse<UserProfile>> {
    return this.request<UserProfile>('/users/profile')
  }

  async updateUserProfile(data: any): Promise<ApiResponse<any>> {
    return this.request<any>('/users/profile', {
      method: 'PATCH',
      body: JSON.stringify(data),
    })
  }

  async getDashboardStats(): Promise<ApiResponse<DashboardStats>> {
    return this.request<DashboardStats>('/users/dashboard-stats')
  }

  // Vendor methods
  async getVendors(): Promise<ApiResponse<{ vendors: Vendor[] }>> {
    return this.request<{ vendors: Vendor[] }>('/vendors')
  }

  async createVendor(data: any): Promise<ApiResponse<Vendor>> {
    return this.request<Vendor>('/vendors', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async getVendorStatus(vendorId: string): Promise<ApiResponse<any>> {
    return this.request<any>(`/vendors/${vendorId}/status`)
  }

  async getVendorDashboard(vendorId: string): Promise<ApiResponse<any>> {
    return this.request<any>(`/vendors/${vendorId}/dashboard`, {
      method: 'POST',
    })
  }

  // Payment methods
  async createPaymentIntent(data: any): Promise<ApiResponse<any>> {
    return this.request<any>('/payments/create-intent', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  async completePayment(data: any): Promise<ApiResponse<any>> {
    return this.request<any>('/payments/complete', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  // Transaction methods
  async getTransactions(params?: any): Promise<ApiResponse<{ transactions: Transaction[] }>> {
    const queryString = params ? new URLSearchParams(params).toString() : ''
    return this.request<{ transactions: Transaction[] }>(`/transactions${queryString ? `?${queryString}` : ''}`)
  }
}

export const apiClient = new ApiClient()