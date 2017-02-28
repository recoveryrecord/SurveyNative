# SurveyNative
Native surveys built from declarative definitions (JSON). Many question types, skip logic etc.

## Features

  - Displays a single question at a time, but allow the user to scroll up to read and change previous answers.
  - Takes input from a JSON file.
  - Many supported question types, including single selection, multiple selection, single text field, additive text fields, segment choice, year picker, date picker, and table-style questions.
  - Support for sub-questions.
  - Support for showing/hiding questions based on previous answers.

## Example Survey

![Video showing example app](/README/survey_video_720.gif "Survey Video")

## JSON Input

[Example JSON Input file](Example/SurveyNative/ExampleQuestions.json)

The expected input is an array of "questions" and a "submit" object, detailing how to submit the answers.

### Keys used in Questions

#### Some keys are standard across all question types.  Others are only present for some question types.

  - **id** (_String_): Required.  Used to key answer.  Also used to check show/hide conditions.

  - **header** (_String_): Required.  May be empty.  Displayed as section header.

  - **question** (_String_): Required. Text to display for question.

  - **question_type** (_String_): Required. One of "single_select", "multi_select", "year_picker", "date_picker", "single_text_field", "multi_text_field", "dynamic_label_text_field", "add_text_field", "segment_select", "table_select".  The chosen type may require additional keys.

  - **sub_questions** (_Array of questions_): Optional. Expected keys in each question are the same as a top-level question, except that header is not required (or shown if provided).  Normally, a sub-question would have a "show_if" key, but it's not required.  The "show_if" section of a sub-question may refer to previous sub-question answers.

  - **show_if** (_Conditions_): Optional.  If not provided, the question will default to being shown.  See the "Structure for Show/Hide question" below for more info.

#### The keys below are specific to certain question types.

  - **options** (_Array of Strings or Other object_): Required for "single_select", "mult_select", "table_select".  The "table_select" does not support the Other object.  The Other object is a JSON object with a key for "title".  When selected, the user may enter text into a text field.

  - **label** (_String_): Optional for "single_text_field".

  - **label_options** (_Array containing Strings or String Arrays_): Required for "dynamic_label_text_field".

  - **input_type** (_String_): Optional for "single_text_field", "dynamic_label_text_field", "add_text_field".  Can be set to "number" to change the default keyboard to the number keyboard for the text field(s).

  - **values** (_Array of String_): Required for "segment_select".  These are the values the user will choose between.

  - **low_tag** (_String_): Optional for "segment_select".  This is a label for the lowest (first) value.

  - **high_tag** (_String_): Optional for "segment_select".  This is a label for the highest (last) value.

  - **table_questions** (_Array of table questions_): Required for "table_select".  Each table question should have a "title" and an "id".

### Structure for Show/Hide question

Whether a question is shown or hidden is dependent on the "show_if" key.  If the key is missing, the default is to show the question.  Both simple conditions and decision trees are supported.  The decision trees can contain other decision trees, so you can have fairly complicated logic.  There is probably some limit to how far you can nest them.

#### Simple Condition Keys

  - **id** (_String_): Required.  This is the id for a question.

  - **subid** (_String_): Optional.  This allows access to answers to "table_select" questions to be used, or any other answer that's within a dictionariy.

  - **operation** (_String_): Required.  Can be "equals", "not equals", "greater than", "greater than or equal to", "less than", or "less than or equal to".

  - **value** (_Any_): Required.  This is the value to compare the answer to.

#### Decision Tree Keys

  - **operation** (_String_): Required.  Can be "or" or "and".  If you need a combination, you should be able to use nesting to get it.

  - **subconditions** (_Array of Simple Conditions or Decision Trees_): Required.

### Submit

The submit object (a peer to "questions") requires only two keys, "button_title" and "url".  Both are required strings.
