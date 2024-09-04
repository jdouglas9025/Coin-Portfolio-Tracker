import gnews
import json
import random
import time

baseFilePath = ''  # Update to base path on current machine

# Total results is at most 150 articles
excludedWebsites = ['coin-turk.com', 'zacks.com', 'forbes.com', 'themissouritimes.com']
primaryNews = gnews.GNews(language='en', country='US', period='7d', max_results=20,
                          exclude_websites=excludedWebsites)
secondaryNews = gnews.GNews(language='en', country='US', period='7d', max_results=10,
                            exclude_websites=excludedWebsites)
tertiaryNews = gnews.GNews(language='en', country='US', period='7d', max_results=5,
                           exclude_websites=excludedWebsites)

bitcoinResults = primaryNews.get_news('Bitcoin')
ethereumResults = primaryNews.get_news('Ethereum')
solanaResults = primaryNews.get_news('Solana Coin')
dogecoinResults = primaryNews.get_news('Dogecoin')
altcoinResults = primaryNews.get_news('Altcoin')

# Sleep for 60 seconds before sending additional requests
time.sleep(60)

coinbaseResults = secondaryNews.get_news('Coinbase')
binanceResults = secondaryNews.get_news('Binance')
uniswapResults = secondaryNews.get_news('Uniswap')
cryptocurrencyResults = tertiaryNews.get_news('Cryptocurrency')
blockchainResults = tertiaryNews.get_news('Blockchain')
defiResults = tertiaryNews.get_news('DeFi')
nftResults = tertiaryNews.get_news('NFT')

rawResult = (bitcoinResults + ethereumResults + solanaResults + dogecoinResults + altcoinResults + coinbaseResults
             + binanceResults + uniswapResults + cryptocurrencyResults + blockchainResults + defiResults + nftResults)

finalResult = []
headlines = set()

for index in range(len(rawResult)):
    # Only include if headline not already present in set
    if rawResult[index]['title'] not in headlines:
        # Get the Newspaper3k instance (contains image) for a particular article
        article = primaryNews.get_full_article(rawResult[index]['url'])

        if article is not None:
            # Get top image (header image)
            image = article.top_image
            # Add as 'imageUrl' attribute
            rawResult[index]['imageUrl'] = image
            # Add to final result
            finalResult.append(rawResult[index])

        # Sleep for 60 seconds after getting 100 articles before sending more requests
        if index != 0 and index % 100 == 0:
            time.sleep(60)

        # Add to set
        headlines.add(rawResult[index]['title'])

# Shuffle list to mix up articles from various topics
random.shuffle(finalResult)

# Write to file for Java app to read
with open(baseFilePath + '/news/newsFeed.txt', 'w') as file:
    json.dump(finalResult, file, ensure_ascii=False)
