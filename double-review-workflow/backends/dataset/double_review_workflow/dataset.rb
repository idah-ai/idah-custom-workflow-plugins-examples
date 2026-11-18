# frozen_string_literal: true

module DoubleReviewWorkflow
  class Dataset
    def self.init(context)
      # Register the custom workflow for this plugin
      context.register_workflow(
        "custom-annotation-workflow",
        klass: DoubleReviewWorkflow::Workflow::CustomAnnotationWorkflow
      )
    end
  end
end
