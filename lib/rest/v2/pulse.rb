module Bitfinex
  module RESTv2Pulse
    ###
    # Get Pulse Profile
    #
    # @param [string] nickname Nickname of pulse profile
    #
    # @return [Hash] the Pulse Profile
    #
    # @see https://docs.bitfinex.com/reference#rest-public-pulse-profile
    ###
    def get_pulse_profile(nickname)
      resp = get("pulse/profile/#{nickname}").body
      Bitfinex::Models::PulseProfile.unserialize(resp)
    end

    ###
    # Get Public Pulse History
    #
    # @param [int] end (optional) Return only the entries after this timestamp
    # @param [int] limit (optional) Limit the number of entries to return. Default is 25.
    #
    # @return [Array] public pulse message
    #
    # @see https://docs.bitfinex.com/reference#rest-public-pulse-hist
    ###
    def get_public_pulse_history(params = {})
      pulses = get("pulse/hist", params).body
      pulses.map { |p| deserialize_pulse_with_profile(p) }
    end

    ###
    # Get Private Pulse History
    #
    # @param [int] isPublic allows to receive the public pulse history with the UID_LIKED field
    #
    # @return [Array] private pulse message
    #
    # @see https://docs.bitfinex.com/reference#rest-auth-pulse-hist
    ###
    def get_private_pulse_history(params = {})
      pulses = authenticated_post("auth/r/pulse/hist", params).body
      pulses.map { |p| deserialize_pulse_with_profile(p) }
    end

    ###
    # Submit new Pulse message
    #
    # @param [Hash] pulse
    #
    # @return [Hash] pulse
    #
    # @see https://docs.bitfinex.com/reference#rest-auth-pulse-add
    ###
    def submit_pulse(pulse)
      resp = authenticated_post("auth/w/pulse/add", params: pulse).body
      Bitfinex::Models::Pulse.unserialize(resp)
    end

    ###
    # Submit Pulse message comment, requires :parent (pulse id) to
    # be present in request payload
    #
    # @param [Hash] pulse
    #
    # @return [Hash] pulse
    #
    # @see https://docs.bitfinex.com/reference#rest-auth-pulse-add
    ###
    def submit_pulse_comment(pulse)
      resp = authenticated_post("auth/w/pulse/add", params: pulse).body
      Bitfinex::Models::Pulse.unserialize(resp)
    end

    ###
    # Delete Pulse message
    #
    # @param [string] id pulse id
    #
    # @return [boolean] true if success, false if error
    #
    # @see https://docs.bitfinex.com/reference#rest-auth-pulse-del
    ###
    def delete_pulse(id)
      resp = authenticated_post("auth/w/pulse/del", params: { :pid => id }).body
      if resp[0] == 1
        return true
      end
      return false
    end

    private

    def deserialize_pulse_with_profile(payload)
      pulse = Bitfinex::Models::Pulse.unserialize(payload)
      if pulse[:profile].any?
        pulse[:profile] = Bitfinex::Models::PulseProfile.unserialize(pulse[:profile][0])
      end
      pulse
    end
  end
end
