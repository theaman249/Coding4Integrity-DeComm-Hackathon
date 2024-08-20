import FlexSearch from 'flexsearch'

const Currency : any ={
	btc : {"btc": null},
	eth : {"eth": null},
	icp : {"icp": null},
	usd : {"usd": null},
	eur : {"eur": null},
	gbp : {"gbp": null},
  }

export type Post = {
	productLongDesc : string
	productCategory : string
	name : string
	productShortDesc: string
	productID: number
	isSold: boolean
	isVisible: boolean
	sellerID : string
	productPrice : productPrice
	productPicture : string
}

export type Result = {
	productLongDesc : string[]
	productCategory : string
	name : string
	productShortDesc: string
	productID: number
	isSold: boolean
	isVisible: boolean
	sellerID : string
	productPrice : productPrice
	productPicture : string
}


export type productPrice = {
	currency : typeof Currency;
	amount: number;
}

let postsIndex: FlexSearch.Index
let posts: Post[]

export function createPostsIndex(data: Post[]) {
	postsIndex = new FlexSearch.Index({ tokenize: 'forward' })

	data.forEach((post, i) => {
		const item = `${post.name} ${post.productLongDesc}`
		postsIndex.add(i, item)
	})

	posts = data
}

export function searchPostsIndex(searchTerm: string) {
	const match = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
	const results = postsIndex.search(match)

	return results
		.map((index) => posts[index as number])
		.map(({ 
			productLongDesc,
			productCategory,
			name,
			productShortDesc,
			productID,
			isSold,
			isVisible,
			sellerID,
			productPrice,
			productPicture,
		 }) => {
			return {
				productLongDesc: getMatches(productLongDesc, match),
				productCategory,
				name: replaceTextWithMarker(name, match),
				productShortDesc,
				productID,
				isSold,
				isVisible,
				sellerID,
				productPrice,
				productPicture,
			}
		})
}

function replaceTextWithMarker(text: string, match: string) {
	const regex = new RegExp(match, 'gi')
	return text.replaceAll(regex, (match) => `<mark>${match}</mark>`)
}

function getMatches(text: string, searchTerm: string, limit = 1) {
	const regex = new RegExp(searchTerm, 'gi')
	const indexes = []
	let matches = 0
	let match

	while ((match = regex.exec(text)) !== null && matches < limit) {
		indexes.push(match.index)
		matches++
	}

	return indexes.map((index) => {
		const start = index - 20
		const end = index + 80
		const excerpt = text.substring(start, end).trim()
		return `...${replaceTextWithMarker(excerpt, searchTerm)}...`
	})
}