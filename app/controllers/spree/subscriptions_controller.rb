class Spree::SubscriptionsController < Spree::BaseController

  def create
    @errors = []

    if params[:email].blank?
      @errors << t('missing_email')
    elsif params[:email] !~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
      @errors << t('invalid_email_address')
    else
      if @mc_member
        @errors << t('that_address_is_already_subscribed')
      else
        begin
          gibbon.lists.subscribe( Spree::Config[:mailchimp_list_id], params[:email], {}, 'html',
                                  false, false, false, true )

        rescue Gibbon::MailChimpError => ex
          @errors << t('that_address_is_already_subscribed')
          logger.warn "SpreeMailChimp: Failed to subscribe user: #{ex.message}\n#{ex.backtrace.join("\n")}"
        end


      end
    end

    respond_to do |format|
      format.js do
        if @errors.empty?
          flash[:success] = Spree.t(:you_have_been_subscribed)
        else
          flash[:error] = Spree.t(:error) + ":" + @errors.join(' / ')
        end
        render 'spree/subscriptions/create'
      end
    end
  end

  private

  def gibbon
    @gibbon ||= Gibbon.new(Spree::Config[:mailchimp_api_key])
  end

end
