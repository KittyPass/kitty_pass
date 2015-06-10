require 'ipaddress'

# Network interfaces belong to a server, and are identified by their name, which must be unique in the scope of
# the server. They have an IPv4 and an IPv6 address as well as a MAC address, which are all validates before save.
class NetworkInterface < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { scope: :networkable, case_sensitive: false }
  validates :mac_address, format: { with: /\A([0-9A-F]{2}[:-]){5}([0-9A-F]{2})\z/i }
  validates :ipv6_prefix, inclusion: { in: 0..128 }, allow_nil: true
  validates :networkable, presence: true

  validate :ipv4_address_and_netmask_present,
           :ipv4_address_has_valid_format,
           :ipv4_netmask_has_valid_format,
           :ipv6_address_and_prefix_present,
           :ipv6_address_has_valid_format

  belongs_to :networkable, polymorphic: true, inverse_of: :network_interfaces

  private

  def ipv4_address_and_netmask_present
    return if (ipv4_address.blank? && ipv4_netmask.blank?) || (ipv4_address.present? && ipv4_netmask.present?)
    errors.add :ipv4_address, I18n.t('network_interface.ipv4_address.incomplete')
  end

  def ipv4_address_has_valid_format
    return if ipv4_address.blank? || IPAddress.valid_ipv4?(ipv4_address)
    errors.add :ipv4_address, I18n.t('network_interface.ipv4_address.invalid_format')
  end

  def ipv4_netmask_has_valid_format
    return if ipv4_netmask.blank? || IPAddress.valid_ipv4_netmask?(ipv4_netmask)
    errors.add :ipv4_netmask, I18n.t('network_interface.ipv4_netmask.invalid_format')
  end

  def ipv6_address_and_prefix_present
    return if (ipv6_address.blank? && ipv6_prefix.blank?) || (ipv6_address.present? && ipv6_prefix.present?)
    errors.add :ipv6_address, I18n.t('network_interface.ipv6_address.incomplete')
  end

  def ipv6_address_has_valid_format
    return if ipv6_address.blank? || IPAddress.valid_ipv6?(ipv6_address)
    errors.add :ipv6_address, I18n.t('network_interface.ipv6_address.invalid_format')
  end
end
