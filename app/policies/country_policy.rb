class CountryPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  alias create?  index?
  alias update?  index?
  alias destroy? index?
end