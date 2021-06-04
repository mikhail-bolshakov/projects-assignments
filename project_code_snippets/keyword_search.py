#################################TASK 1
"""A researcher has gathered thousands of news articles. But she wants to focus her attention on articles including a specific word. Complete the function below to help her filter her list of articles.
Your function should meet the following criteria:
Do not include documents where the keyword string shows up only as a part of a larger word. For example, if she were looking for the keyword “closed”, you would not include the string “enclosed.”
She does not want you to distinguish upper case from lower case letters. So the phrase “Closed the case.” would be included when the keyword is “closed”
Do not let periods or commas affect what is matched. “It is closed.” would be included when the keyword is “closed”. But you can assume there are no other types of punctuation."""

###############################Option 1
# def word_search(doc_list, keyword):
#     search_result = []
#     for index, element in enumerate(doc_list):
#         words = element.lower().replace(".", "").replace(",", "").split(" ")
#         #print(words)
#         if keyword in words:
#             [search_result.append(index)]
#     return search_result

# print(text_manipulation(doc_list, keyword))


# ====================================Option 2
# def word_search(documents, keyword):
#     # list to hold the indices of matching documents
#     indices = []
#     # Iterate through the indices (i) and elements (doc) of documents
#     for i, doc in enumerate(documents):
#         # Split the string doc into a list of words (according to whitespace)
#         tokens = doc.split()
#         # Make a transformed list where we 'normalize' each word to facilitate matching.
#         # Periods and commas are removed from the end of each word, and it's set to all lowercase.
#         normalized = [token.rstrip('.,').lower() for token in tokens]
#         # Is there a match? If so, update the list of matching indices.
#         if keyword.lower() in normalized:
#             indices.append(i)
#     return indices

#################################TASK 2
"""Now the researcher wants to supply multiple keywords to search for. Complete the function below to help her.
(You're encouraged to use the word_search function you just wrote when implementing this function. Reusing code in this way makes your programs more robust and readable - and it saves typing!)
"""


def multi_word_search(doc_list, keywords):
    """
    Takes list of documents (each document is a string) and a list of keywords.
    Returns a dictionary where each key is a keyword, and the value is a list of indices
    (from doc_list) of the documents containing that keyword

    >>> doc_list = ["The Learn Python Challenge Casino.", "They bought a car and a casino", "Casinoville"]
    >>> keywords = ['casino', 'they']
    >>> multi_word_search(doc_list, keywords)
    {'casino': [0, 1], 'they': [1]}
    """
    search_result_dic = {}

    for keyword in keywords:
        search_result = []
        for index, element in enumerate(doc_list):
            words = element.lower().replace(".", "").replace(",", "").split(" ")

            if keyword in words:
                print(keyword in words, words, keyword, index)
                search_result.append(index)
        search_result_dic[keyword] = search_result
    return search_result_dic


# doc_list = [
#     "The Learn Python Challenge Casino.",
#     "They bought a car and a casino",
#     "Casinoville",
# ]
doc_list = []
# keywords = ["casino", "they"]
keywords = ["casino"]

print(multi_word_search(doc_list, keywords))
