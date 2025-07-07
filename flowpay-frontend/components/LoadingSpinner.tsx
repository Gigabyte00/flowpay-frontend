import FlowPayLogo from './FlowPayLogo'

export default function LoadingSpinner() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 flex items-center justify-center">
      <div className="animate-pulse">
        <FlowPayLogo size="large" />
      </div>
    </div>
  )
}