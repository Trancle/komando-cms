/* HTML5 -> Flash fallback for browsers that understand HTML5, but not any video encodings */
/** Wojno Systems, Inc. HTML5 Video Tag Fallback manipulators and Video Player API
 * v0.2
 * Copyright (c) 2011 Wojno Systems, Inc.
 * support@wojnosystems.com
 */
function com_wojnosystems_can_play_any_source(a){var b=jQuery(a);if(b.attr("type")!=void 0)return b[0].canPlayType(b.attr("type"));var c="";jQuery(a+" > source").each(function(){var a=b[0].canPlayType(this.type);b[0].canPlayType(this.type)!=""&&(c=a)});return c}
function com_wojnosystems_html5_to_flash_fallback(a){if(com_wojnosystems_can_play_any_source(a)==""){var b=jQuery(a+" > object");jQuery(b).clone().appendTo(jQuery(a).parent().parent());jQuery(a).parent().remove();return!0}return!1}