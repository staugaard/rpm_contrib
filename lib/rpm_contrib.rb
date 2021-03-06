
RPM_CONTRIB_LIB = File.dirname(__FILE__)

module RPMContrib
  VERSION = File.read(RPM_CONTRIB_LIB+"/../CHANGELOG")[/Version ([\d\.]+)$/, 1]
end

# Perform any framework/dispatcher detection before loading the rpm
# gem.

raise "The rpm_contrib gem must be loaded before the newrelic_rpm gem." if defined?(::NewRelic)

Dir.glob(RPM_CONTRIB_LIB + "/rpm_contrib/detection/**/*.rb") { |file| require file }

require 'newrelic_rpm'

init_sequence = Proc.new do
  
  # Tell the agent to load all the files in the
  # rpm_contrib/instrumentation directory.
  NewRelic::Agent.add_instrumentation(RPM_CONTRIB_LIB+"/rpm_contrib/instrumentation/**/*.rb")

  # Load all the Sampler class definitions.  These will register
  # automatically with the agent.
  Dir.glob(RPM_CONTRIB_LIB + "/rpm_contrib/samplers/**/*.rb") { |file| require file }
end

if defined?(Rails.configuration)
  Rails.configuration.after_initialize &init_sequence
else
  init_sequence.call
end


