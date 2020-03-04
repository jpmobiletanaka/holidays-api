class HolidayPolicy < ApplicationPolicy
  def index?
    user&.present?
  end

  def create?
    user&.admin?
  end

  alias update?  create?
  alias destroy? create?
  alias move? create?
  alias show? create?
end
