# frozen_string_literal: true

a = 228
raise TypeError, "Expected type Integer, got a.class" unless a.is_a?(Integer)

b = "322"
raise TypeError, "Expected type String, got b.class" unless b.is_a?(String)
