import json

import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel

baseFilePath = ''  # Update to base path on current machine

# Get data from source file
dataFrame = pd.read_csv(baseFilePath + '/metadata/descriptions.csv')

# Look for most frequently occurring + most important terms to find similarities
# Excludes any stop words (non-relevant words)
tfidf = TfidfVectorizer(stop_words='english')

# Get vectors from source data using description column
vectors = tfidf.fit_transform(dataFrame['description'])

# Get cosine similarity values
cosineSimilarities = linear_kernel(vectors)

# Create indices for looking up matches for a coin by name
indices = pd.Series(dataFrame.index, index=dataFrame['coinId'])


def getRecommendations(coinId):
    index = indices[coinId]

    # Get relative cosine (includes self) for this index
    similarityScores = enumerate(cosineSimilarities[index])
    similarityScores = sorted(similarityScores, key=lambda x: x[1], reverse=True)

    # Get top 5 most similar (exclude self)
    similarityScores = similarityScores[1:6]

    # Get ids for matches
    matchingIndices = [i[0] for i in similarityScores]

    return dataFrame['coinId'].iloc[matchingIndices].values.tolist()


# Maps input coin name to list of matches
dictionary = {}

for coinId in dataFrame['coinId']:
    # Put new mapping into dict with name as key mapped to array of matches
    dictionary[coinId] = getRecommendations(coinId)

# Write JSON to file for Java app to read
with open(baseFilePath + '/metadata/recommendations.txt', 'w') as file:
    json.dump(dictionary, file, ensure_ascii=False)
