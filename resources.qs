const Resources  = [{
	name : "resource1",
	desc : "Композиты",
	icon : "🧱"
}, {
	name : "resource2",
	desc : "Механизмы",
	icon : "⚙️"
}, {
	name : "resource3",
	desc : "Реагенты",
	icon : "🛢"
}];

function getResourceInfo(r, c) {
	return Resources[r].desc + `: ${c}` + Resources[r].icon;
}

function getResourceCount(r, c) {
	return `${c}` + Resources[r].icon;
}
