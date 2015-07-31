# -*- coding: utf-8 -*-
class UserObjectModel < ApplicationModel
  # 既定クラス定義
  self.abstract_class = true

  # before_save :regist_abstract_user
  after_save :regist_abstract_user

  has_one :abstract_user, :as => :user_object, :dependent=>:destroy

  #++++++++++++++++++++++++++++++++++++++++++++++++++
  # accessor
  #++++++++++++++++++++++++++++++++++++++++++++++++++
  attr_accessor :allow_attach_account  # Accountとの自動アタッチ許可

  #++++++++++++++++++++++++++++++++++++++++++++++++++
  # Delegates メソッドを委譲
  #++++++++++++++++++++++++++++++++++++++++++++++++++
  delegate :attach_apps_gate_profile, 
           :dettach_apps_gate_profile,
           :enable_relation_apps_gate_profile_and_abstract_user,
           :enable_apps_gate_profile,
           :to=>:abstract_user

  #==================================================
  # accountアタッチ可能？
  #　accountをアタッチしてよい状態かをチェックする
  # ※画面上からの更新時、自動アタッチをする確認実施したかのみをチェック
  #==================================================
  def attachable_account?( account )
    logger.info "target_person:" + self.inspect
    logger.info "target_account:" + account.inspect
    logger.info "allow_attach_account:" + self.allow_attach_account.inspect
    
    return true if self.allow_attach_account.nil? # 指定なしの場合は、OKとする
    if self.allow_attach_account == true or self.allow_attach_account == "true"
      true
    elsif self.abstract_user.has_account?( account )
      # 既に関連づいているAccountの場合は、OK
      true
    else
      false
    end
  end

  def regist_abstract_user
    if self.abstract_user.nil?
      self.build_abstract_user()
      self.abstract_user.customer_id = self.customer_id
    end
    self.abstract_user.regist_abstract_user( :name=>self.abstract_user_name )
  end

  #==================================================
  # 関連づけ削除
  #　削除時に実施されるコールバック
  #==================================================
  def destroy_relations
  end

  def abstract_user_name
    ""
  end

  #==================================================================
  # 所有しているアカウント情報を取得
  #==================================================================
  def enable_account_objects
    return [] if self.abstract_user.nil?
    
    result = self.abstract_user.enable_abstract_accounts.select{|abstract_account| !abstract_account.account_object.blank? and abstract_account.account_object.enabled }
    result.map {|abstract_account| abstract_account.account_object }
  end

  #==================================================================
  # 所有しているAppsアカウント情報を取得
  #==================================================================
  def enable_apps_accounts
    account_objects = self.enable_account_objects
    # Appsアカウントのみの情報にフィルタする
    account_objects.select{|account_object| account_object.is_a?(AppsAccount) and !account_object.apps_domain.nil? and account_object.apps_domain.enabled }
  end

  #==================================================================
  # 所有しているSFDCアカウント情報を取得
  #==================================================================
  def enable_sfdc_accounts
    account_objects = self.enable_account_objects
    # SFDCアカウントのみの情報にフィルタする
    account_objects.select{|account_object| account_object.is_a?(SfdcAccount) and !account_object.sfdc_domain.nil? and account_object.sfdc_domain.enabled }
  end

  #==================================================================
  # 所有しているデバイス情報を取得
  #==================================================================
  def enable_devices
    return [] if self.abstract_user.nil?

    self.abstract_user.enable_devices
  end

end
