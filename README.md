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

The expected input is an array of `questions` and a `submit` object, detailing how to submit the answers.

### Keys used in Questions

#### Some keys are standard across all question types. Others are only present for some question types.

  - `id` (_String_): Required. Used to key answer. Also used to check show/hide conditions.

  - `header` (_String_): Optional. Displayed as section header.

  - `question` (_String_): Required. Text to display for question.

  - `question_type` (_String_): Required. The chosen type may require additional keys.
    - `single_select` [screenshot](#single_select) | [json](#single_select)
    - `multi_select` [screenshot](#multi_select) | [json](#multi_select)
    - `year_picker` [screenshot](#year_picker) | [json](#year_picker)
    - `date_picker` [screenshot](#date_picker) | [json](#date_picker)
    - `single_text_field` [screenshot](#single_text_field) | [json](#single_text_field)
    - `multi_text_field` [screenshot](#multi_text_field) | [json](#multi_text_field)
    - `dynamic_label_text_field` [screenshot](#dynamic_label_text_field) | [json](#dynamic_label_text_field)
    - `add_text_field` [screenshot](#add_text_field) | [json](#add_text_field)
    - `segment_select` [screenshot](#segment_select) | [json](#segment_select)
    - `table_select` [screenshot](#table_select) | [json](#table_select)

  - `sub_questions` (_Array of questions_): Optional. Expected keys in each question are the same as a top-level question, except that header is not required (or shown if provided). Normally, a sub-question would have a `show_if` key, but it's not required. The `show_if` section of a sub-question may refer to previous sub-question answers.

  - `show_if` (_Conditions_): Optional. If not provided, the question will default to being shown. See the [Structure for Show/Hide question](#structure-for-showhide-question) below for more info.

#### The keys below are specific to certain question types.

  - `options` (_Array of Strings or Other object_): Required for `single_select`, `mult_select`, `table_select` question_types. The `table_select` does not support the Other object. The Other object is a JSON object with a key for `title`. When selected, the user may enter text into a text field.

  - `label` (_String_): Optional for `single_text_field` question type.

  - `label_options` (_Array containing Strings or String Arrays_): Required for `dynamic_label_text_field`.

  - `input_type` (_String_): Optional for `single_text_field`, `dynamic_label_text_field`, `add_text_field` question_types. Can be set to `number` to change the default keyboard to the number keyboard for the text field(s).

  - `max_chars` (_String_): Options for `single_text_field` and `multi_text_field` question_types.  Determines the max number of characters the user may enter.

  - `validations` (_Array of Dictionaries_): Optional for `single_text_field` and `dynamic_label_text_field` question_types. Check value meets the validations when `Next` tapped. If not `validationFailed(message: String)` is called on your `ValidationFailedDelegate`. Validations consist of attributes:
  	-  `operation`
  	-  `value` or `answer_to_question_id`
  	-  `on_fail_message`
  	-  `for_label` (only used for `dynamic_label_text_field`)
  	
  	Supported operations:

    - `equals`
    - `not equals`
    - `greater than`
    - `greater than or equal to`
    - `less than`
    - `less than or equal to`

  - `values` (_Array of String_): Required for `segment_select` question_type. These are the values the user will choose between.

  - `fields` (_Array of Dictionaries_): Required for `multi_text_field` question_type.  Each dictionary must contain a `label` key and an `input_type` key.

  - `low_tag` (_String_): Optional for `segment_select` question_type. This is a label for the lowest (first) value.

  - `high_tag` (_String_): Optional for `segment_select` question_type. This is a label for the highest (last) value.

  - `table_questions` (_Array of table questions_): Required for `table_select` question_type. Each table question should have a `title` and an `id` attribute.

  - `min_year` (_String_): Optional for `year_picker` question_type.  Can be an integer or "current_year". See [More about Year Picker](#more-about-year-picker) below for more info.

  - `max_year` (_String_): Optional for `year_picker` question_type.  Can be an integer or "current_year". See [More about Year Picker](#more-about-year-picker) below for more info.

  - `num_years` (_String_): Optional for `year_picker` question_type.  See [More about Year Picker](#more-about-year-picker) below for more info.

  - `initial_year` (_String_): Optional for `year_picker` question_type.  If set, this year will be selected when the picker is first opened.

  - `sort_order` (_String_): Optional for `year_picker` question_type.  May be "ASC" (ascending) or "DESC" (descending).  Defaults to "ASC".

  - `date` (_String in YYYY-MM-dd format or "current_date"_): Optional for `date_picker` question_type.  If specified, the picker will initially be set to this value (unless the question is already answered, in which case it will be set to the previous answer).  If unset, defaults to the current date.

  - `max_date` (_String in YYYY-MM-dd format or "current_date"_): Optional for `date_picker` question_type.  If specified, the picker will not allow the user to choose a date later than this.  If min_date is specified and min_date > max_date, both values will be ignored.

  - `min_date` (_String in YYYY-MM-dd format or "current_date"_): Optional for `date_picker` question_type.  If specified, the picker will not allow the user to choose a date earlier than this.  If min_date is specified and min_date > max_date, both values will be ignored.

  - `date_diff` (_Dictionary of String to Int values_): Optional for `date_picker` question_type.  Valid keys are `day`, `month`, and `year`.  Only takes effect if exactly one of `min_date` and `max_date` is set.  The unset min/max value will be set by adding the affect of this to the set min/max value.  `date_diff` should be overall positive if `min_date` is set and negative if `max_date` is set.  If `date_diff` is set such that `min_date` > `max_date`, both values will be ignored.


#### More about Year Picker

You only need to specify two of `min_year`, `max_year`, and `num_years`.  The missing values will be calculated from what is provided.  If all three are provided, the `num_years` value will be ignored.  If less than two values are provided, we'll guess reasonable values for the missing ones.

### Structure for Show/Hide question

Whether a question is shown or hidden is dependent on the `show_if` key. If the key is missing, the default is to show the question. Both simple conditions and decision trees are supported. The decision trees can contain other decision trees, so you can have fairly complicated logic. There is probably some limit to how far you can nest them.

#### Simple Condition Keys

  - `id` (_String_): Required. This is the id for a question.

  - `subid` (_String_): Optional. This allows access to answers to `table_select` questions to be used, or any other answer that's within a dictionariy.

  - `operation` (_String_): Required. Supported operations:
    - `equals`
    - `not equals`
    - `greater than`
    - `greater than or equal to`
    - `less than`
    - `less than or equal to`
    - `contains`
    - `not contains`

  - `value` (_Any_): Required. This is the value to compare the answer to.

#### Decision Tree Keys

  - `operation` (_String_): Required. Can be `or` or `and`. If you need a combination, you should be able to use nesting to get it.

  - `subconditions` (_Array of Simple Conditions or Decision Trees_): Required.

#### Custom Conditions

If these options are inadequate, you can set a _CustomConditionDelegate_ and use it to make the show/hide decision.

  - `ids` (_Array of Strings_): Required.  Must be non-empty. These are the ids for questions the your delegate needs the answers to in order to perform it's show/hide calculation.  Your delegate will be called as soon as any of the questions are answered, so you may have nil data for one or more answers.

  - `operation` (_String_): Required. Should be set to 'custom'.

  - `extra` (_Dictionary with String keys_): Optional. This will be passed to the _isConditionMet_ method of your _CustomConditionDelegate_.

### Submit

The submit object (a peer to `questions`) requires only two keys, `button_title` and `url`. Both are required strings.

### Question Type Examples

#### single_select

```
{
  "id": "ice_cream",
  "header": "Question 1",
  "question": "What is your favorite ice cream flavor?",
  "question_type": "single_select",
  "options": [
    "Strawberry",
    "Chocolate",
    "Vanilla",
    {
      "title": "Other",
      "type": "freeform"
    }
  ]
}
```

![](/README/ice_cream_0.png "single_select example")

#### multi_select

```
{
  "id": "music_types",
  "header": "Question 6",
  "question": "What types of music do you like?",
  "question_type": "multi_select",
  "options": [
    "Pop",
    "Rock",
    "Rap",
    "Country",
    {
      "title": "Other",
      "type": "freeform"
    }
  ]
}
```

![](/README/music_types_0.png "multi_select example")

#### year_picker

```
{
  "id": "birthyear",
  "header": "Question 2",
  "question": "Enter the year of your birth.",
  "question_type": "year_picker"
  "max_year" : "current_year",
  "num_years" : "125",
  "sort_order" : "DESC"
}
```

![](/README/birthyear_0.png "year_picker example")

#### date_picker

```
{
  "id": "date",
  "header": "Question 11",
  "question": "What is was the best day of the last year?",
  "question_type": "date_picker",
  "date" : "current_date",
  "max_date" : "current_date",
  "date_diff" : { "year" : -1 },
}
```

#### single_text_field

```
{
  "id": "age",
  "header": "Question 4",
  "question": "What is your current age in years?",
  "question_type": "single_text_field",
  "label": "Years",
  "input_type": "number",
  "max_chars": "2",
  "validations": [
    {
      "operation": "greater than",
      "value": 10,
      "on_fail_message": "Age must be at least 10"
    },
    {
      "operation": "less than",
      "value": 80,
      "on_fail_message": "You must be 80 or younger"
    }
  ]
}
```

![](/README/age_0.png "single_text_field example")

#### multi_text_field
```
{
  "id":"pets",
  "header": "Question 12",
  "question": "How many pets do you have?",
  "question_type": "multi_text_field",
  "fields": [
    {
      "label" : "Dogs",
      "input_type" : "number"
    },
    {
      "label" : "Cats",
      "input_type" : "number"
    }
  ]
}
```

![](/README/pets_0.png "multi_text_field example")


#### dynamic_label_text_field

```
{
  "id": "height",
  "header": "Question 7",
  "question": "How tall are you?",
  "question_type": "dynamic_label_text_field",
  "label_options": [
    [
      "Feet",
      "Inches"
    ],
    "Centimeters"
  ],
  "options_metadata": {
    "id": "unit_system",
    "types": [
      "imperial",
      "metric"
    ]
  },
  "input_type": "number",
  "validations": [
    {
      "for_label": "Feet",
      "operation": "greater than",
      "value": 3,
      "on_fail_message": "Height must be at least 4 feet"
    },
    {
      "for_label": "Feet",
      "operation": "less than",
      "value": 10,
      "on_fail_message": "Height must be less than 10 feet"
    },
    {
      "for_label": "Centimeters",
      "operation": "greater than",
      "value": 100,
      "on_fail_message": "Height must be at least 100cm"
    },
    {
      "for_label": "Centimeters",
      "operation": "less than",
      "value": 250,
      "on_fail_message": "Height must be less than 250cm"
    }
  ]
}
```

![](/README/height_0.png "dynamic_label_text_field example")

#### add_text_field

```
{
  "id": "which_sports",
  "question": "Which sports do you like to play?",
  "question_type": "add_text_field",
  "input_type": "default"
}
```

![](/README/which_sports_0.png "add_text_field example")

#### segment_select

```
{
  "id": "happiness",
  "header": "Question 8",
  "question": "How happy are you?",
  "question_type": "segment_select",
  "low_tag": "Not happy",
  "high_tag": "Super happy",
  "values": [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7"
  ]
}
```

![](/README/happiness_0.png "segment_select example")

#### table_select

```
{
  "id": "weekend_activities",
  "header": "Question 9",
  "question": "On the weekends, do you:",
  "question_type": "table_select",
  "options": [
    "Yes",
    "Sometimes",
    "No"
  ],
  "table_questions": [
    {
      "title": "Play sports?",
      "id": "play_sports"
    },
    {
      "title": "Read books?",
      "id": "read_books"
    },
    {
      "title": "Go dancing",
      "id": "go_dancing"
    },
    {
      "title": "Watch TV and movies?",
      "id": "watch_tv"
    }
  ]
}
```

![](/README/weekend_activities_0.png "table_select example")

### Contributing

Areas we'd love to see contributions:

- Bug fixes
- Support for `optional` boolean flag on every question type that adds a skip button.
- New question types
- Customizable styling
- Customizable animation
- Dynamic question number substitution in header
- Option to enable/disable animations
- Android Port
- Export qualtrics/survey-monkey surveys to SurveyNative
- CareKit/ResearchKit integration
