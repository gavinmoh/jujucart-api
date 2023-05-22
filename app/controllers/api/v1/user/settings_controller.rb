class Api::V1::User::SettingsController < Api::V1::User::ApplicationController
  before_action :authorize_setting, only: [:show, :update]

  def show
    render json: { setting: settings }, status: :ok
  end
  
  def update
    @errors = ActiveModel::Errors.new(Setting)
    setting_params.keys.each do |key|
      next if setting_params[key].nil?

      setting = Setting.new(var: key)
      if setting_params[key].is_a?(String)
        setting.value = setting_params[key].strip
      else
        setting.value = setting_params[key]
      end
      unless setting.valid?
        @errors.merge!(setting.errors)
      end
    end
    
    if @errors.any?
      render json: { error: @errors }, status: :unprocessable_entity
    else
      setting_params.keys.each do |key|
        if setting_params[key].is_a?(String)
          Setting.send("#{key}=", setting_params[key].strip) unless setting_params[key].nil?
        else
          Setting.send("#{key}=", setting_params[key]) unless setting_params[key].nil?
        end
      end
      render json: { setting: settings }, status: :ok
    end
  end

  private
    def setting_params
      params.require(:setting).permit(:web_host, :coin_to_cash_rate, :order_reward_amount, maximum_redeemed_coin_rate)
    end

    def setting_keys
      [:web_host, :coin_to_cash_rate, :order_reward_amount, :maximum_redeemed_coin_rate]
    end

    def settings
      all_settings = {};
      setting_keys.each do |key|
        all_settings[key] = Setting.send(key)
      end
      return all_settings
    end

    def authorize_setting
      authorize(Setting, policy_class: Api::V1::User::SettingPolicy)
    end

    def set_setting
      @setting = Setting.find_by(var: params[:name])
      raise ActiveRecord::RecordNotFound if @setting.nil?
    end
end