// Steps to update the Emoji picker:
//
// 1. Determine what version of Emoji that Roblox currently supports,
//    and adjust `highest_version` accordinly.
// 2. Download the data file and place it in the same directory as this
//    script.
//    <https://github.com/iamcal/emoji-data/blob/master/emoji.json>
// 3. Make sure you have Node.js installed, probably version 14 or
//    higher will work.
// 4. Open a terminal with the current directory set to the project
//    root. Run `node create_emoji_list.js`.
// 5. The file will be too big for Rojo to sync live, so you either need
//    to rebuild the place/model file or manually copy
//    src/Emoji/Data.lua into Studio.

const emojiData = require("./emoji.json");
const fs = require("fs");

// This should track the most recent version of Emoji that Roblox supports.
const highest_version = 12.1;

const categories = new Map();

for (const emoji of emojiData) {
	const version = parseFloat(emoji.added_in);
	if (version <= highest_version) {
		let category = categories.get(emoji.category);
		if (!category) {
			category = [];
			categories.set(emoji.category, category);
		}
		category.push(emoji);
	}
}

const categoryList = [];
for (const [key, category] of categories) {
	category.sort((a, b) => a.sort_order - b.sort_order);
	categoryList.push({
		name: key,
		items: category,
	});
}

categoryList.sort((a, b) => a.items[0].sort_order - b.items[0].sort_order);

const lines = [];
lines.push("-- Automatically generated with create_emoji_list.js");
lines.push("");
lines.push("return {");
for (const { name, items } of categoryList) {
	lines.push(`\t{`);
	lines.push(`\t\tname = "${name}",`);
	lines.push(`\t\titems = {`);
	for (const item of items) {
		const text = item.unified
			.split("-")
			.map((str) => `\\u{${str}}`)
			.join("");
		const alts = [];
		for (const [key, alt] of Object.entries(item.skin_variations || {})) {
			const id = parseInt(key, 16);
			// https://unicode.link/codepoint/1F3FB-emoji-modifier-fitzpatrick-type-1-2
			const index = id - 0x1f3fb + 2;
			const value = alt.unified
				.split("-")
				.map((str) => `\\u{${str}}`)
				.join("");
			alts.push(`[${index}] = "${value}"`);
		}
		const altsStr = alts.join(", ");
		const shortName = item.short_name.replace(/_/g, "-");

		lines.push("\t\t\t{");
		lines.push(`\t\t\t\tname = "${shortName}",`);
		lines.push(`\t\t\t\tbase = "${text}",`);
		if (alts.length > 0) {
			lines.push(`\t\t\t\talts = { ${altsStr} },`);
		}
		lines.push(`\t\t\t},`);
	}
	lines.push(`\t\t},`);
	lines.push("\t},");
}
lines.push("}");

fs.writeFileSync("src/Emoji/Data.lua", lines.join("\n"), {
	encoding: "utf-8",
});
