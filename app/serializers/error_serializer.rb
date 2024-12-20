class ErrorSerializer
  def self.format_errors(messages)
    {
      message: 'Your query could not be completed',
      errors: messages
    }
  end

  def self.format_invalid_search_response
    { 
      message: "your query could not be completed", 
      errors: ["invalid search params"] 
    }
  end
  
  def self.format_coupon_deactivation_response
    {
    message: "Your query could not be completed",
    errors: ["Cannot deactivate a coupon that's attached to invoices"]
  }
  end

  def self.format_update_active_only
    {
      message: "Your query could not be completed",
      errors: ["The active parameter is required to change the active status"]
    }
  end
end