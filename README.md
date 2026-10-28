# Add Post Menu Button
Discourse Workflows is an awesome plugin! But currently, there's not a way for the Post Menu Button node to navigate a user to a Workflows form.

This theme component adds a button in the post menu of one or more selected categories, which opens an optionally pre-filled Workflows form in a new tab.

## Features
* **Create multiple buttons in one theme component:** Install the theme component once and use the objects setting editor to create multiple different buttons, all independent of each other.
* **Enable for any category:** You're able to indicate one or as many categories as you'd like, and have the option to include subcategories.
* **Enable for any group:** You're able to restrict the button to one or more groups, or allow everyone to use it.
* **Select your own icon:** Use any FontAwesome icon for the button.
* **Automatically pass the topic id and the post id to the Workflows form:** An optional feature that can kickstart powerful workflows without the user having to declare a topic id or post id.
* **Prefill selected fields:** Pass any text that gets prefilled in the form's field when the user clicks the button.

## Settings

All settings are within the Objects setting editor.

Form button:

| Name | Field Type | Description |
| :--- | :--- | :--- |
| Rule Name | string | Internal label to identify this rule in the settings editor |
| Enabled Categories | string | Category number where this form button will appear - enter multiple category numbers with a pipe separator |
| Include Subcategories | checkbox | Also display this button in subcategories of the selected categories |
| Allowed Groups | groups selector | Only show this button to members of these groups, leave empty to allow everyone |
| First Post Only | checkbox | Only show the button on the original post (post #1) of a topic |
| Base Form URL | string | The base URL of your Workflows form (e.g., https://example.com/form) |
| Automatically pass topic_id and post_id | checkbox | Automatically appends ?topic_id=...&post_id=... to the Form URL" |
| Button Icon | string | FontAwesome 6 icon name |
| Button Tooltip | string | Hover title and screen-reader label for the button |

Form parameters:

| Name | Field Type | Description |
| :--- | :--- | :--- |
| Form Field Name | string | EXACT name/label of the field in your form (spaces are automatically encoded) - use the Custom field name if applied to the field, otherwise use the Label field |
| Field Value | string | Static text or dynamic placeholders: {post_id}, {post_number}, {topic_id}, {topic_slug}, {topic_title}, {category_id}, {category_name}, {username}, {user_id}, {post_url}, {current_username}, {current_user_id} |

## Examples

### Object settings editor

<img width="1091" height="1581" alt="image" src="https://github.com/user-attachments/assets/f843b62b-eb59-46f4-b791-25dc96bcd31d" />


### Form parameters

<img width="1090" height="641" alt="image" src="https://github.com/user-attachments/assets/8f647670-f4f1-49e6-81b6-e355f72071e3" />


### Post menu
The button will appear on the left side of the menu.

<img width="524" height="98" alt="image" src="https://github.com/user-attachments/assets/34e30ebe-3b63-4e28-8193-6556bc9cc1e2" />


