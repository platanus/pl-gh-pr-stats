class GetReviewRecommendations < PowerTypes::Command.new(:github_user_id, :other_users_ids)
  REVIEW_MONTH_LIMIT = 1
  REVIEW_WEEK_LIMIT = 1
  NUMBER_OF_RECOMMENDATIONS = 3

  def perform
    sorted_map =
      times_reviewed_by_each_user
      .sort_by { |_, times_reviewed| times_reviewed }
    {
      best: best_recommendations(sorted_map, NUMBER_OF_RECOMMENDATIONS),
      worst: worst_recommendations(sorted_map, NUMBER_OF_RECOMMENDATIONS)
    }
  end

  private

  def times_reviewed_by_each_user
    appearance_counter =
      PullRequestRelation
      .review_relations
      .within_month_limit(REVIEW_MONTH_LIMIT)
      .where(github_user_id: @other_users_ids, target_user_id: @github_user_id)
      .pluck(:github_user_id)
      .each_with_object(Hash.new(0)) { |user_id, counter| counter[user_id] += 1 }
    fill_missing_users_from_appearance_counter(appearance_counter)
    add_last_week_reviews_weight_to_appearance_counter(appearance_counter)
    appearance_counter
  end

  def fill_missing_users_from_appearance_counter(appearance_counter)
    @other_users_ids.each do |other_user_id|
      unless appearance_counter.key? other_user_id
        appearance_counter[other_user_id] = 0
      end
    end
  end

  def last_week_reviews_weight
    last_week_weights =
      PullRequestRelation
      .review_relations
      .within_week_limit(REVIEW_WEEK_LIMIT)
      .where(github_user_id: @other_users_ids, target_user_id: @github_user_id)
      .pluck(:github_user_id)
      .each_with_object(Hash.new(0)) { |user_id, counter| counter[user_id] += 2 }
    fill_missing_users_from_appearance_counter(last_week_weights)
    last_week_weights
  end

  def add_last_week_reviews_weight_to_appearance_counter(appearance_counter)
    last_week_weights = last_week_reviews_weight
    @other_users_ids.each do |other_user_id|
      appearance_counter[other_user_id] += last_week_weights[other_user_id]
    end
  end

  def best_recommendations(sorted_map, number_of_recommendations)
    sorted_map.first(number_of_recommendations).map { |user_id, _| GithubUser.find(user_id) }
  end

  def worst_recommendations(sorted_map, number_of_recommendations)
    sorted_map.last(number_of_recommendations).map { |user_id, _| GithubUser.find(user_id) } - best_recommendations(sorted_map, number_of_recommendations)
  end
end