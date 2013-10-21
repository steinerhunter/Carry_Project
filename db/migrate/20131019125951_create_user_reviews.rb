class CreateUserReviews < ActiveRecord::Migration
  def change
    create_table :user_reviews do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.string :req_or_sugg
      t.integer :task_id
      t.string :job_type
      t.string :pos_or_neg
      t.string :review_content

      t.timestamps
    end
    add_index :user_reviews, :from_user_id
    add_index :user_reviews, :to_user_id
    add_index :user_reviews, :req_or_sugg
    add_index :user_reviews, :task_id
    add_index :user_reviews, [:from_user_id, :to_user_id, :req_or_sugg, :task_id ], unique: true, name: "unique_user_reviews_index"
  end
end
