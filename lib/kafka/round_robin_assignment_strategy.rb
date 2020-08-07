# frozen_string_literal: true

module Kafka

  # A consumer group partition assignment strategy that assigns partitions to
  # consumers in a round-robin fashion.
  class RoundRobinAssignmentStrategy
    # Assign the topic partitions to the group members.
    #
    # @param cluster [Kafka::Cluster]
    # @param members [Hash<String, Kafka::Protocol::JoinGroupResponse::Metadata>] a hash
    #   mapping member ids to metadata
    # @param partitions [Array<Kafka::ConsumerGroup::Assignor::Partition>] a list of
    #   partitions the consumer group processes
    # @return [Hash<String, Array<Kafka::ConsumerGroup::Assignor::Partition>] a hash
    #   mapping member ids to partitions.
    def assign(cluster:, members:, partitions:)
      member_ids = members.keys
      partitions_per_member = Hash.new {|h, k| h[k] = [] }
      partitions.each_with_index do |partition, index|
        partitions_per_member[member_ids[index % member_ids.count]] << partition
      end

      partitions_per_member
    end
  end
end

require "kafka/consumer_group/assignor"
strategy = Kafka::RoundRobinAssignmentStrategy.new
Kafka::ConsumerGroup::Assignor.register_strategy(:roundrobin) do |cluster:, members:, partitions:|
  strategy.assign(cluster: cluster, members: members, partitions: partitions)
end
