# frozen_string_literal: true

module NanoidGenerator
  extend ActiveSupport::Concern

  included do
    before_create :set_nanoid
  end

  NANOID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"
  NANOID_LENGTH = 10
  MAX_RETRY = 1000

  NANO_ID_REGEX = /[#{NANOID_ALPHABET}]{#{NANOID_LENGTH}}\z/

  class_methods do
    def generate_nanoid(alphabet: NANOID_ALPHABET, size: NANOID_LENGTH)
      Nanoid.generate(size: size, alphabet: alphabet)
    end
  end

  def set_nanoid
    return unless self.respond_to?(:nanoid)
    return if nanoid.present?
    MAX_RETRY.times do
      self.nanoid = generate_nano_id
      return unless self.class.where(nanoid: nanoid).exists?
    end
    raise "Failed to generate a unique nano id after #{MAX_RETRY} attempts"
  end

  def generate_nano_id
    self.class.generate_nanoid(alphabet: NANOID_ALPHABET)
  end
end