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
