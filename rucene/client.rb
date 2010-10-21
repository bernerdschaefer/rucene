class Rucene
  def self.run!(options)
    jruby = JRubyJars.core_jar_path
    jruby_stdlib = JRubyJars.stdlib_jar_path

    java_args = [
      "-cp", [JRubyJars.core_jar_path, JRubyJars.stdlib_jar_path].join(":"),
      "org.jruby.Main"
    ]

    server = fork do
      ENV["RUBYOPT"] = "-rubygems"
      exec("java", *(java_args + ["rucene.rb", options[:port].to_s]))
    end

    at_exit { Process.kill(:INT, server); Process.waitpid(server) }

    sleep 0.1 until (TCPSocket.open("localhost", options[:port].to_i) rescue nil)
  end
end

