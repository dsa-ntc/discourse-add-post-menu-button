import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

function isCategoryMatch(category, rule) {
  if (!category || !rule.enabled_categories) {
    return false;
  }

  const allowedIds = String(rule.enabled_categories)
    .split(/[|,]/)
    .map((id) => parseInt(id.trim(), 10))
    .filter(Boolean);

  if (allowedIds.length === 0) {
    return false;
  }

  if (allowedIds.includes(category.id)) {
    return true;
  }

  if (
    rule.include_subcategories &&
    category.parent_category_id &&
    allowedIds.includes(category.parent_category_id)
  ) {
    return true;
  }

  return false;
}

function isGroupMatch(user, rule) {
  const allowedGroupIds = rule.allowed_groups;
  if (!Array.isArray(allowedGroupIds) || allowedGroupIds.length === 0) {
    return true;
  }

  if (allowedGroupIds.includes(0) || allowedGroupIds.includes("0")) {
    return true;
  }

  if (!user || !Array.isArray(user.groups)) {
    return false;
  }

  return user.groups.some((group) => allowedGroupIds.includes(group.id));
}

function doesRuleMatch(rule, post, user) {
  if (!post?.topic?.category || !rule?.form_url) {
    return false;
  }

  if (rule.first_post_only && post.post_number !== 1) {
    return false;
  }

  if (!isGroupMatch(user, rule)) {
    return false;
  }

  return isCategoryMatch(post.topic.category, rule);
}

function interpolatePlaceholders(rawString, replacements, encodeValues = false) {
  let result = String(rawString ?? "");
  for (const [placeholder, val] of Object.entries(replacements)) {
    const replacement = encodeValues
      ? encodeURIComponent(val ?? "")
      : String(val ?? "");
    result = result.replaceAll(placeholder, replacement);
  }
  return result;
}

function createRuleButtonComponent(rule, index, currentUser) {
  return class PostFormLinkButton extends Component {
    @service currentUser;

    static shouldRender(args) {
      return doesRuleMatch(rule, args.post, currentUser);
    }

    get buttonClass() {
      return `post-action-menu__form-link post-action-menu__form-link--${index}`;
    }

    get buttonIcon() {
      return rule.button_icon || "file-lines";
    }

    get buttonTitle() {
      return rule.button_title || "Open form";
    }

    get targetUrl() {
      const post = this.args.post;
      const topic = post.topic;
      const category = topic?.category;
      const fullPostUrl = `${window.location.origin}${post.url}`;

      const replacements = {
        "{post_id}": post.id,
        "{post_number}": post.post_number,
        "{topic_id}": topic?.id,
        "{topic_slug}": topic?.slug,
        "{topic_title}": topic?.title,
        "{category_id}": topic?.category_id,
        "{category_name}": category?.name,
        "{username}": post.username,
        "{user_id}": post.user_id,
        "{post_url}": fullPostUrl,
        "{current_username}": this.currentUser?.username,
        "{current_user_id}": this.currentUser?.id,
      };

      const baseUrlString = interpolatePlaceholders(
        rule.form_url,
        replacements,
        true
      );

      let parsedUrl;
      try {
        parsedUrl = new URL(baseUrlString, window.location.origin);
      } catch {
        return baseUrlString;
      }

      if (rule.include_default_ids !== false) {
        if (topic?.id != null) {
          parsedUrl.searchParams.set("topic_id", String(topic.id));
        }
        if (post?.id != null) {
          parsedUrl.searchParams.set("post_id", String(post.id));
        }
      }

      if (Array.isArray(rule.form_params)) {
        rule.form_params.forEach((param) => {
          const key = param.field_name?.trim();
          if (!key) {
            return;
          }
          const resolvedValue = interpolatePlaceholders(
            param.field_value,
            replacements,
            false
          );
          parsedUrl.searchParams.set(key, resolvedValue);
        });
      }

      return parsedUrl.toString();
    }

    @action
    openForm() {
      if (this.targetUrl) {
        window.open(this.targetUrl, "_blank", "noopener,noreferrer");
      }
    }

    <template>
      <DButton
        class={{this.buttonClass}}
        ...attributes
        @action={{this.openForm}}
        @icon={{this.buttonIcon}}
        @translatedTitle={{this.buttonTitle}}
      />
    </template>
  };
}

export default apiInitializer((api) => {
  const currentUser = api.getCurrentUser();

  api.registerValueTransformer(
    "post-menu-buttons",
    ({ value: dag, context: { firstButtonKey } }) => {
      const rules = settings.form_buttons;
      if (!Array.isArray(rules)) {
        return;
      }

      rules.forEach((rule, index) => {
        const key = `post-form-link-${index}`;
        const ButtonComponent = createRuleButtonComponent(
          rule,
          index,
          currentUser
        );

        // Always display directly on the main post action bar
        dag.add(key, ButtonComponent, {
          after: firstButtonKey,
        });
      });
    }
  );
});
