# frozen_string_literal: true

require 'rails_helper'

describe DismissTopics do
  fab!(:user) { Fabricate(:user) }
  fab!(:category) { Fabricate(:category) }
  fab!(:topic1) { Fabricate(:topic, category: category, created_at: 60.minutes.ago) }
  fab!(:topic2) { Fabricate(:topic, category: category, created_at: 120.minutes.ago) }

  before do
    user.user_stat.update!(new_since: 1.days.ago)
  end

  describe '#perform!' do
    it 'dismisses two topics' do
      expect { described_class.new(user, Topic.all).perform! }.to change { DismissedTopicUser.count }.by(2)
    end

    it 'respects max_new_topics limit' do
      SiteSetting.max_new_topics = 1
      expect { described_class.new(user, Topic.all).perform! }.to change { DismissedTopicUser.count }.by(1)

      dismissed_topic_user = DismissedTopicUser.last

      expect(dismissed_topic_user.user_id).to eq(user.id)
      expect(dismissed_topic_user.topic_id).to eq(topic1.id)
      expect(dismissed_topic_user.created_at).not_to be_nil
    end

    it 'respects new_topic_duration_minutes' do
      user.user_option.update!(new_topic_duration_minutes: 70)

      expect { described_class.new(user, Topic.all).perform! }.to change { DismissedTopicUser.count }.by(1)

      dismissed_topic_user = DismissedTopicUser.last

      expect(dismissed_topic_user.user_id).to eq(user.id)
      expect(dismissed_topic_user.topic_id).to eq(topic1.id)
      expect(dismissed_topic_user.created_at).not_to be_nil
    end
  end
end
